//
//  ApplicationConfig.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit
import Alamofire

public class ApplicationConfig {
    
    public static let RemoteConfigURL: URL = URL(string: "http://thesimulatorcompanysecure.com/remoteConfig.php")!
    
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    private let fileLocalData: URL
    private let fileCachedRemoteData: URL
    private let folderCachedVideos: URL
    private let folderCachedCustomVideos: URL
    
    private var remoteData: RemoteData
    private var localData: LocalData
    
    init() {
        
        fileLocalData = FileHelper.getLocalFile("localData.json")
        fileCachedRemoteData = FileHelper.getLocalFile("cachedRemoteData.json")
        folderCachedVideos = FileHelper.getLocalDirectory("cachedVideos")
        folderCachedCustomVideos = FileHelper.getLocalDirectory("cachedCustomVideos")
        
        encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        decoder = JSONDecoder()
        
        do {
            localData = try LocalData.fromJSON(decoder: decoder, string: try FileHelper.readUTF8(fileLocalData))
        } catch let error {
            RemoteLog("Unable to load local data! \(error)")
            localData = LocalData()
        }
        
        do {
            remoteData = try RemoteData.fromJSON(decoder: decoder, string: try FileHelper.readUTF8(fileCachedRemoteData))
            
            try RemoteLog(FileHelper.readUTF8(fileCachedRemoteData))
        } catch let error {
            RemoteLog("Unable to load remote data! \(error)")
            remoteData = RemoteData()
        }
    }
    
    public func getLicenseInfo() -> LicenseInformation? {
        return localData.license
    }
    
    public func getDefaultMode() -> String? {
        
        for mode in remoteData.modeDefinitions {
            return mode.key
        }
        
        for mode in localData.customModeDefinitions {
            return mode.key
        }
        
        return nil
    }
    
    public func getDefaultView(modeKey: String) -> String? {
        
        for view in remoteData.viewDefinitions {
            if(view.modeKey.compare(modeKey) == .orderedSame) {
                return view.key
            }
        }
        
        for view in localData.customViewDefinitions {
            if(view.modeKey.compare(modeKey) == .orderedSame) {
                return view.key
            }
        }
        return nil
    }
    
    public func updateRemoteConfigAsync(_ statusCallback: ((String) async -> Void)? = nil, _ percentageCallback: ((Float) async -> Void)? = nil) async throws {
        await percentageCallback?(0)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        await statusCallback?("Downloading remote config...")
        let request = URLRequest(url: ApplicationConfig.RemoteConfigURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 15.0)
        let (data, _) = try await session.data(for: request)
        RemoteLog("Remote data: \(String(data: data, encoding: .utf8)!)")
        remoteData = try RemoteData.fromJSON(decoder: decoder, string: String(data: data, encoding: .utf8)!)
        await statusCallback?("Caching remote config...")
        try FileHelper.writeUTF8(fileCachedRemoteData, try remoteData.toJSON(encoder: encoder))
        try await updateCache(statusCallback, percentageCallback)
    }
    
    
    public func updateRemoteConfigAsync(statusCompletion: @escaping ((String) async -> Void), percentageCompletion: @escaping ((Float) async -> Void)) async throws {
        await percentageCompletion(0)
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        await statusCompletion("Downloading remote config...")
        let request = URLRequest(url: ApplicationConfig.RemoteConfigURL, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 15.0)
        let (data, _) = try await session.data(for: request)
        RemoteLog("Remote data: \(String(data: data, encoding: .utf8)!)")
        remoteData = try RemoteData.fromJSON(decoder: decoder, string: String(data: data, encoding: .utf8)!)
        await statusCompletion("Caching remote config...")
        try FileHelper.writeUTF8(fileCachedRemoteData, try remoteData.toJSON(encoder: encoder))
        try await updateCache(statusCompletion, percentageCompletion)
    }
    
    public func updateCache(_ statusCallback: ((String) async -> Void)? = nil, _ percentageCallback: ((Float) async -> Void)? = nil) async throws {
        await statusCallback?("Clearing cached videos...")
        await percentageCallback?(0)
        do {
            try FileHelper.clearDirectory(folderCachedVideos)
        } catch let error {
            RemoteLog("Unable to clear video directory: \(error)")
        }
        for videoData in localData.videoDatas {
            videoData.cachedPathRelative = nil
        }
        try FileHelper.mkdirs(folderCachedVideos)
        for i in 0...(remoteData.videoRemoteDatas.count - 1) {
            await percentageCallback?(Float(i) / Float(remoteData.videoRemoteDatas.count))
            let videoRemoteData = remoteData.videoRemoteDatas[i]
            do {
                await statusCallback?("Caching \(i + 1) out of \(remoteData.videoRemoteDatas.count)...")
                let targetURLOpt = URL(string: videoRemoteData.url)
                guard let targetURL = targetURLOpt else {
                    // throw RuntimeError.runtimeError("Invalid URL: \(videoRemoteData.url)")
                    throw RuntimeError(message: "Invalid URL: \(videoRemoteData.url)")
                }
                let request = URLRequest(url: targetURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60 * 10)
                let (data, response) = try await URLSession.shared.data(for: request)
                RemoteLog(response.description)
                let cachedPathRelative = "\(videoRemoteData.videoRef.modeKey)_\(videoRemoteData.videoRef.viewKey)_\(videoRemoteData.videoRef.pointKey).\(targetURL.pathExtension)"
                let cachedURL = FileHelper.file(folderCachedVideos, cachedPathRelative)
                RemoteLog("Data size: \(data.count)")
                try FileHelper.writeData(cachedURL, data)
                try RemoteLog("\(FileManager.default.attributesOfItem(atPath: cachedURL.path)[.size] ?? 0)")
                getLocalVideoData(videoRemoteData.videoRef).cachedPathRelative = cachedPathRelative
            } catch let error {
                RemoteLog("Unable to cache video \(videoRemoteData.videoRef.toString()): \(error)")
            }
        }
        
        await statusCallback?("Storing local data...")
        try FileHelper.writeUTF8(fileLocalData, localData.toJSON(encoder: encoder))
        await statusCallback?("Done!")
        await percentageCallback?(1)
    }
    
    public func trySaveLocalData() {
        do {
            try FileHelper.writeUTF8(fileLocalData, localData.toJSON(encoder: encoder))
        } catch let error {
            RemoteLog("Error storing local data: \(error)")
        }
    }
    
    public func setLicenseInfo(_ licenseInfo: LicenseInformation) {
        localData.license = licenseInfo
        trySaveLocalData()
    }
    
    // MARK: - Get Mode -
    
    public func getTotalModeCount() -> Int {
        return getDefaultModeCount() + getCustomModeCount()
    }
    
    public func getDefaultModeCount() -> Int {
        return remoteData.modeDefinitions.count
    }
    
    public func getCustomModeCount() -> Int {
        return localData.customModeDefinitions.count
    }
    
   
    
    public func getMode(index: Int) -> ModeDefinition? {
        
        if(index < 0 || index >= getTotalModeCount()) {
            return nil
        }
        
        if(index >= remoteData.modeDefinitions.count) {
            return localData.customModeDefinitions[index - remoteData.modeDefinitions.count]
        }
        
        return remoteData.modeDefinitions[index]
    }
    
    public func getViewCount(modeKey: String) -> Int {
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                cnt += 1
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                cnt += 1
            }
        }
        return cnt
    }
    
    public func getDefaultViewCount(modeKey: String) -> Int {
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                cnt += 1
            }
        }
        return cnt
    }
    
    public func getViewDefinition(modeKey: String, index: Int) -> ViewDefinition? {
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                if(cnt == index) {
                    return viewDef
                }
                cnt += 1
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                if(cnt == index) {
                    return viewDef
                }
                cnt += 1
            }
        }
        return nil
    }
    
    public func getViewDefinition(modeKey: String, viewKey: String) -> ViewDefinition? {
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame && viewDef.key.compare(viewKey) == .orderedSame) {
                return viewDef
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame && viewDef.key.compare(viewKey) == .orderedSame) {
                return viewDef
            }
        }
        return nil
    }
    
    public func getAccessPointCount() -> Int {
        
        return remoteData.pointDefinitions.count
    }
    
    public func getAccessPoint(index: Int) -> AccessPointDefinition? {
        
        if(index < 0 || index >= getAccessPointCount()) {
            return nil
        }
        
        return remoteData.pointDefinitions[index]
    }
    
    public func getAccessPoint(key: String) -> AccessPointDefinition? {
        
        for pointDefinition in remoteData.pointDefinitions {
            if(pointDefinition.key.compare(key) == .orderedSame) {
                return pointDefinition
            }
        }
        
        return nil
    }
    
    public func getAccessPointLocalData(key: String) -> AccessPointLocalData? {
        
        RemoteLog("getAccesPointLocalData for \(key)...")
        RemoteLog("\(localData.pointDatas)")
        
        for pointDefinition in localData.pointDatas {
            if(pointDefinition.key.compare(key) == .orderedSame) {
                RemoteLog("Found!");
                return pointDefinition
            }
        }
        
        RemoteLog("Not found!");
        
        localData.pointDatas.append(AccessPointLocalData(key: key, code: ""))
        return localData.pointDatas[localData.pointDatas.count - 1]
    }
    
    public func setAccessPointCode(key: String, code: String) {
        
        for ap in localData.pointDatas {
            if(ap.key.compare(key) == .orderedSame) {
                ap.code = code
            } else if(ap.code.compare(code) == .orderedSame) {
                ap.code = ""
            }
        }
        
        trySaveLocalData()
    }
    
    private func uncacheCustomVideo(videoRef: VideoReference, videoData: VideoLocalData? = nil) {
        
        let vd = videoData ?? getLocalVideoData(videoRef)
        
        guard let pathRelative = vd.cachedOverridePathRelative else {
            return
        }
        
        let url = FileHelper.file(folderCachedCustomVideos, pathRelative)
        
        if(FileManager.default.fileExists(atPath: url.path)) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error {
                RemoteLog("Unable to uncache video for \(videoRef.toString()): \(error)")
            }
        }
        
        vd.cachedOverridePathRelative = nil
    }
    
    /*private func cacheCustomVideo(videoRef: VideoReference, url: URL, videoData: VideoLocalData? = nil) async {
     
     let vd = videoData ?? getLocalVideoData(videoRef)
     
     do {
     try FileHelper.mkdirs(folderCachedCustomVideos)
     let (tmpUrl, _) = try await URLSession.shared.download(from: url)
     let cachedPathRelative = "\(videoRef.modeKey)_\(videoRef.viewKey)_\(videoRef.pointKey).\(url.pathExtension)"
     let cachedURL = FileHelper.file(folderCachedCustomVideos, cachedPathRelative)
     try FileHelper.moveFile(tmpUrl, cachedURL)
     vd.cachedOverridePathRelative = cachedPathRelative
     } catch let error {
     RFIDVideoPlayer.RemoteLog("Unable to cache video \(videoRef.toString()): \(error)")
     }
     }*/
    
    /*public func cacheCustomVideo(videoRef: VideoReference, url: URL, customVideoData: CustomVideoData) async {
        
        uncacheCustomVideoData(customVideoData: customVideoData)
        
        do {
            try FileHelper.mkdirs(folderCachedCustomVideos)
            let (data, _) = try await URLSession.shared.data(from: url)
            let cachedPathRelative = "\(videoRef.modeKey)_\(videoRef.viewKey)_\(videoRef.pointKey)_\(videoRef.instanceKey).\(url.pathExtension)"
            let cachedURL = FileHelper.file(folderCachedCustomVideos, cachedPathRelative)
            try data.write(to: cachedURL)
            customVideoData.cachedPathRelative = cachedPathRelative
            trySaveLocalData()
        } catch let error {
            RemoteLog("Unable to cache video \(videoRef.toString()): \(error)")
        }
    }*/
    
    public func cacheCustomVideo(videoRef: VideoReference, url: URL, customVideoData: CustomVideoData, successCompletion: @escaping (Any)->Void) async {
            
        uncacheCustomVideoData(customVideoData: customVideoData)
        
        do {
            try FileHelper.mkdirs(folderCachedCustomVideos)
            let (data, _) = try await URLSession.shared.data(from: url)
            let cachedPathRelative = "\(videoRef.modeKey)_\(videoRef.viewKey)_\(videoRef.pointKey)_\(videoRef.instanceKey).\(url.pathExtension)"
            let cachedURL = FileHelper.file(folderCachedCustomVideos, cachedPathRelative)
            try data.write(to: cachedURL)
            customVideoData.cachedPathRelative = cachedPathRelative
            trySaveLocalData()
            AF.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(url, withName: "video", fileName: url.lastPathComponent, mimeType: "video/\(url.pathExtension)")
                for (key, value) in EndPoints.cachVideo().1 {
                    multipartFormData.append(value.data(using: .utf8)!, withName: key)
                }
            }, to: EndPoints.cachVideo().0)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    successCompletion(value)
                    print("Success: \(value)")
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            
        } catch let error {
            USIM.RemoteLog("Unable to cache video \(videoRef.toString()): \(error)")
        }
    }
    
    public func setVideoToDefault(videoRef: VideoReference) {
        
        let vd = getLocalVideoData(videoRef)
        
        uncacheCustomVideo(videoRef: videoRef, videoData: vd)
        trySaveLocalData()
    }
    
    /*public func setCustomVideoURL(videoRef: VideoReference, url: URL) async {
     
     let vd = getLocalVideoData(videoRef)
     
     uncacheCustomVideo(videoRef: videoRef, videoData: vd)
     await cacheCustomVideo(videoRef: videoRef, url: url, videoData: vd)
     trySaveLocalData()
     }*/
    
    private func getLocalVideoData(_ ref: VideoReference) -> VideoLocalData {
        
        for videoData in localData.videoDatas {
            if(videoData.videoRef == ref) {
                return videoData
            }
        }
        
        let d = VideoLocalData(videoRef: ref)
        localData.videoDatas.append(d)
        return d
    }
    
    public func getMode(modeKey: String) -> ModeDefinition? {
        
        for mode in remoteData.modeDefinitions {
            if(mode.key.compare(modeKey) == .orderedSame) {
                return mode
            }
        }
        for mode in localData.customModeDefinitions {
            if(mode.key.compare(modeKey) == .orderedSame) {
                return mode
            }
        }
        
        return nil
    }
    
    public func isModeNotCustom(modeKey: String) -> Bool {
        
        for mode in remoteData.modeDefinitions {
            if(mode.key.compare(modeKey) == .orderedSame) {
                return true
            }
        }
        
        return false
    }
    
    public func getAccessPointKeyFromCode(code: String) -> String? {
        
        for pointData in localData.pointDatas {
            if(pointData.code.compare(code) == .orderedSame) {
                for remoteData in remoteData.pointDefinitions {
                    if(remoteData.key.compare(pointData.key) == .orderedSame) {
                        return pointData.key
                    }
                }
            }
        }
        
        return nil
    }
    
    public func getCachedVideoURLs(pointKey: String, modeKey: String, viewKey: String) -> [(String, URL)] {
        
        RemoteLog("Let's try get videos for \(modeKey)_\(viewKey)_\(pointKey)!")
        
        var videos: [(String, URL)] = []
        
        for customVideoData in localData.customVideoDatas {
            RemoteLog("Let's check against \(customVideoData.videoRef.modeKey)_\(customVideoData.videoRef.viewKey)_\(customVideoData.videoRef.pointKey)")
            if(customVideoData.videoRef.pointKey.compare(pointKey) == .orderedSame &&
               customVideoData.videoRef.modeKey.compare(modeKey) == .orderedSame &&
               customVideoData.videoRef.viewKey.compare(viewKey) == .orderedSame) {
                RemoteLog("Equal!")
                if let pr = customVideoData.cachedPathRelative {
                    RemoteLog("We have a cached path! \(FileHelper.file(folderCachedCustomVideos, pr).absoluteString)")
                    videos.append((customVideoData.videoRef.instanceKey, FileHelper.file(folderCachedCustomVideos, pr)))
                }
            }
        }
        
        for videoData in localData.videoDatas {
            if(videoData.videoRef.pointKey.compare(pointKey) == .orderedSame &&
               videoData.videoRef.modeKey.compare(modeKey) == .orderedSame &&
               videoData.videoRef.viewKey.compare(viewKey) == .orderedSame) {
                if let overridePathRelative = videoData.cachedOverridePathRelative {
                    videos.append((videoData.videoRef.instanceKey, FileHelper.file(folderCachedCustomVideos, overridePathRelative)))
                }
                if let pathRelative = videoData.cachedPathRelative {
                    videos.append((videoData.videoRef.instanceKey, FileHelper.file(folderCachedVideos, pathRelative)))
                }
            }
        }
        
        return videos
    }
    
    public func getCachedVideoURL(videoRef: VideoReference) -> URL? {
        
        RemoteLog("Let's try get videos for \(videoRef)!")
        
        
        for customVideoData in localData.customVideoDatas {
            RemoteLog("Let's check against \(customVideoData.videoRef.modeKey)_\(customVideoData.videoRef.viewKey)_\(customVideoData.videoRef.pointKey)")
            if(customVideoData.videoRef == videoRef) {
                RemoteLog("Equal!")
                if let pr = customVideoData.cachedPathRelative {
                    RemoteLog("We have a cached path! \(FileHelper.file(folderCachedCustomVideos, pr).absoluteString)")
                    return FileHelper.file(folderCachedCustomVideos, pr)
                }
            }
        }
        
        for videoData in localData.videoDatas {
            if(videoData.videoRef == videoRef) {
                if let overridePathRelative = videoData.cachedOverridePathRelative {
                    return FileHelper.file(folderCachedCustomVideos, overridePathRelative)
                }
                if let pathRelative = videoData.cachedPathRelative {
                    return FileHelper.file(folderCachedVideos, pathRelative)
                }
            }
        }
        
        return nil
    }
    
    public func addCustomMode(modeKey: String, name: String) {
        
        localData.customModeDefinitions.append(ModeDefinition(key: modeKey, name: name))
        trySaveLocalData()
    }
    
    public func addCustomView(modeKey: String, viewKey: String, name: String) {
        
        localData.customViewDefinitions.append(ViewDefinition(key: viewKey, modeKey: modeKey, name: name))
        trySaveLocalData()
    }
    
    public func getAllCustomMedia(modeKey: String, viewKey: String) -> [CustomVideoData] {
        var datas: [CustomVideoData] = []
        for d in localData.customVideoDatas {
            if(d.videoRef.modeKey.compare(modeKey) == .orderedSame) && (d.videoRef.viewKey.compare(viewKey) == .orderedSame)  {
                datas.append(d)
            }
        }
        return datas
    }
    
    public func addCustomVideoData(videoRef: VideoReference, name: String, cachedPathRelative: String?) {
        
        var d = CustomVideoData(videoRef: videoRef, name: name)
        d.cachedPathRelative = cachedPathRelative
        localData.customVideoDatas.append(d)
        trySaveLocalData()
    }
    
    public func deleteCustomMode(modeKey: String) {
        
        localData.customModeDefinitions.removeAll() {
            element in
            return element.key.compare(modeKey) == .orderedSame
        }
        
        localData.customViewDefinitions.removeAll() {
            element in
            return element.modeKey.compare(modeKey) == .orderedSame
        }
        
        for d in localData.customVideoDatas {
            if(d.videoRef.modeKey.compare(modeKey) == .orderedSame) {
                uncacheCustomVideoData(customVideoData: d, save: false)
            }
        }
        
        localData.customVideoDatas.removeAll() {
            element in
            return element.videoRef.modeKey.compare(modeKey) == .orderedSame
        }
        
        trySaveLocalData()
    }
    
    public func deleteCustomView(modeKey: String, viewKey: String) {
        
        localData.customViewDefinitions.removeAll() {
            element in
            return element.modeKey.compare(modeKey) == .orderedSame && element.key.compare(viewKey) == .orderedSame
        }
        
        for d in localData.customVideoDatas {
            if(d.videoRef.modeKey.compare(modeKey) == .orderedSame && d.videoRef.viewKey.compare(viewKey) == .orderedSame) {
                uncacheCustomVideoData(customVideoData: d, save: false)
            }
        }
        
        localData.customVideoDatas.removeAll() {
            element in
            return element.videoRef.modeKey.compare(modeKey) == .orderedSame && element.videoRef.viewKey.compare(viewKey) == .orderedSame
        }
        
        trySaveLocalData()
    }
    public func getViewIndex(modeKey: String, viewKey: String) -> Int? {
        
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                if(viewDef.key.compare(viewKey) == .orderedSame) {
                    return cnt
                }
                cnt += 1
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeKey.compare(modeKey) == .orderedSame) {
                if(viewDef.key.compare(viewKey) == .orderedSame) {
                    return cnt
                }
                cnt += 1
            }
        }
        return nil
    }
    
    public func getAccessPointIndex(pointKey: String) -> Int? {
        
        var cnt: Int = 0
        
        for p in remoteData.pointDefinitions {
            if(p.key.compare(pointKey) == .orderedSame) {
                return cnt
            }
            cnt += 1
        }
        
        return nil
    }
    
    public func getCustomVideoDataIndexFromLocalIndex(modeKey: String, localIndex: Int) -> Int? {
        
        var index = 0
        var cnt = 0
        for d in localData.customVideoDatas {
            if(d.videoRef.modeKey.compare(modeKey) == .orderedSame) {
                if(cnt == localIndex) {
                    return index
                }
                cnt += 1
            }
            index += 1
        }
        
        return nil
    }
    
    public func uncacheCustomVideoData(customVideoData: CustomVideoData, save: Bool = true) {
        
        if let path = customVideoData.cachedPathRelative {
            let url = FileHelper.file(folderCachedCustomVideos, path)
            if(FileManager.default.fileExists(atPath: url.path)) {
                do {
                    try FileManager.default.removeItem(at: url)
                    customVideoData.cachedPathRelative = nil
                    if(save) {
                        trySaveLocalData()
                    }
                } catch let error {
                    RemoteLog("Unable to remove cached video: \(error)")
                }
            }
        }
    }
    
    public func removeCustomVideoData(modeKey: String, localIndex: Int) {
        
        if let index = getCustomVideoDataIndexFromLocalIndex(modeKey: modeKey, localIndex: localIndex) {
            
            let cvd = localData.customVideoDatas[index]
            uncacheCustomVideoData(customVideoData: cvd, save: false)
            
            localData.customVideoDatas.remove(at: index)
            trySaveLocalData()
        }
    }
    
    public func getDefaultVideos() -> [VideoReference] {
        
        var vids: [VideoReference] = []
        
        for videoData in remoteData.videoRemoteDatas {
            vids.append(videoData.videoRef)
        }
        
        return vids
    }
    
    public func getVideoInstanceIndex(_ videoRef: VideoReference) -> Int {
        
        var ind = 0
        
        for videoData in remoteData.videoRemoteDatas {
            if(videoData.videoRef.pointKey.compare(videoRef.pointKey) == .orderedSame &&
               videoData.videoRef.modeKey.compare(videoRef.modeKey) == .orderedSame &&
               videoData.videoRef.viewKey.compare(videoRef.viewKey) == .orderedSame) {
                if(videoData.videoRef.instanceKey.compare(videoRef.instanceKey) == .orderedSame) {
                    break
                }
                
                ind += 1
            }
        }
        
        return ind
    }
    
    /*public func initDummyData() async {
     
     remoteData = RemoteData()
     remoteData.modeDefinitions.append(ModeDefinition(key: "mode1", name: "Mode 1"))
     remoteData.modeDefinitions.append(ModeDefinition(key: "mode2", name: "Mode 2"))
     
     remoteData.pointDefinitions.append(AccessPointDefinition(key: "point1", name: "Point 1"))
     remoteData.pointDefinitions.append(AccessPointDefinition(key: "point2", name: "Point 2"))
     
     remoteData.videoRemoteDatas.append(VideoRemoteData(videoRef: VideoReference(modeKey: "mode1", pointKey: "point1"), url: Bundle.main.url(forResource: "sample", withExtension: "mp4")!))
     
     do {
     try FileHelper.writeUTF8(fileCachedRemoteData, try remoteData.toJSON(encoder: encoder))
     } catch let error {
     RFIDVideoPlayer.RemoteLog("Unable to save dummy remote data: \(error)")
     }
     
     localData = LocalData()
     localData.pointDatas.append(AccessPointLocalData(key: "point1", code: "1111111111"))
     localData.pointDatas.append(AccessPointLocalData(key: "point2", code: "0004292654"))
     
     do {
     try FileHelper.writeUTF8(fileLocalData, try localData.toJSON(encoder: encoder))
     } catch let error {
     RFIDVideoPlayer.RemoteLog("Unable to save dummy local data: \(error)")
     }
     
     do {
     try await updateCache() {
     status in
     RFIDVideoPlayer.RemoteLog("Updating Cache: \(status)")
     }
     } catch let error {
     RFIDVideoPlayer.RemoteLog("Unable to save dummy local data: \(error)")
     }
     }*/
    
    public func debugPrint() {
        do {
            
            try print("LocalConfig: \(String(data: encoder.encode(localData), encoding: .utf8) ?? "")")
            try print("RemoteConfig: \(String(data: encoder.encode(remoteData), encoding: .utf8) ?? "")")
            print("Cached videos:")
            
            for file in try FileManager.default.contentsOfDirectory(atPath: folderCachedVideos.path) {
                print(folderCachedVideos.appendingPathComponent(file))
            }
            
            print("Cached Custom videos:")
            
            for file in try FileManager.default.contentsOfDirectory(atPath: folderCachedCustomVideos.path) {
                print(folderCachedCustomVideos.appendingPathComponent(file))
            }
            
        } catch let error {
            print("Unable to debug print: \(error)")
        }
    }
}
