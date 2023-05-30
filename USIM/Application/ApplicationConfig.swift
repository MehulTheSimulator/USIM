//
//  ApplicationConfig.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit
import Alamofire
import AVFoundation

public class ApplicationConfig {
    
    public static let RemoteConfigURL: URL = URL(string: "http://thesimulatorcompanysecure.com/api/all-list")!
    
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
    
    public func getDefaultMode() -> Int? {
        
        for mode in remoteData.modeDefinitions {
            return mode.id
        }
        
        for mode in localData.customModeDefinitions {
            return mode.id
        }
        
        return nil
    }
    
    public func getDefaultView(modeid: Int) -> Int? {
        
        for view in remoteData.viewDefinitions {
            if(view.modeid == modeid) {
                return view.id
            }
        }
        
        for view in localData.customViewDefinitions {
            if(view.modeid == modeid) {
                return view.id
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
                let targetURLOpt = URL(string: videoRemoteData.url!)
                guard let targetURL = targetURLOpt else {
                    // throw RuntimeError.runtimeError("Invalid URL: \(videoRemoteData.url)")
                    throw RuntimeError(message: "Invalid URL: \(videoRemoteData.url)")
                }
                let request = URLRequest(url: targetURL, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60 * 10)
                let (data, response) = try await URLSession.shared.data(for: request)
                RemoteLog(response.description)
                let cachedPathRelative = "\(videoRemoteData.mode_id)_\(videoRemoteData.view_id)_\(videoRemoteData.point_id).\(targetURL.pathExtension)"
                let cachedURL = FileHelper.file(folderCachedVideos, cachedPathRelative)
                RemoteLog("Data size: \(data.count)")
                try FileHelper.writeData(cachedURL, data)
                try RemoteLog("\(FileManager.default.attributesOfItem(atPath: cachedURL.path)[.size] ?? 0)")
                getLocalVideoData(videoRemoteData).cachedPathRelative = cachedPathRelative
            } catch let error {
                RemoteLog("Unable to cache video \(videoRemoteData.toString()): \(error)")
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
    
    public func getViewCount(modeid: Int) -> Int {
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeid == modeid) {
                cnt += 1
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeid == modeid) {
                cnt += 1
            }
        }
        return cnt
    }
    
    public func getDefaultViewCount(modeid: Int) -> Int {
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeid == modeid) {
                cnt += 1
            }
        }
        return cnt
    }
    
    public func getViewDefinition(modeid: Int, index: Int) -> ViewDefinition? {
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeid == modeid) {
                if(cnt == index) {
                    return viewDef
                }
                cnt += 1
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeid == modeid) {
                if(cnt == index) {
                    return viewDef
                }
                cnt += 1
            }
        }
        return nil
    }
    
    public func getViewDefinition(modeid: Int, viewid: Int) -> ViewDefinition? {
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeid == modeid && viewDef.id == viewid) {
                return viewDef
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeid == modeid && viewDef.id == viewid) {
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
    
    public func getAccessPoint(id: Int) -> AccessPointDefinition? {
        
        for pointDefinition in remoteData.pointDefinitions {
            if(pointDefinition.id == id) {
                return pointDefinition
            }
        }
        return nil
    }
    
    public func getAccessPointLocalData(id: Int) -> AccessPointLocalData? {
        
        RemoteLog("getAccesPointLocalData for \(id)...")
        RemoteLog("\(localData.pointDatas)")
        for pointDefinition in localData.pointDatas {
            if(pointDefinition.id == id) {
                RemoteLog("Found!");
                return pointDefinition
            }
        }
        RemoteLog("Not found!");
        localData.pointDatas.append(AccessPointLocalData(id: id, code: ""))
        return localData.pointDatas[localData.pointDatas.count - 1]
    }
    
    public func setAccessPointCode(id: Int, code: String) {
        
        for ap in localData.pointDatas {
            if(ap.id == id) {
                ap.code = code
            } else if(ap.code.compare(code) == .orderedSame) {
                ap.code = ""
            }
        }
        
        trySaveLocalData()
    }
    
    private func uncacheCustomVideo(videoRef: VideoRemoteData, videoData: VideoLocalData? = nil) {
        
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
    
    public func cacheCustomVideo(videoRef: VideoRemoteData, url: URL, customVideoData: CustomVideoData) async throws -> UIImage? {

        uncacheCustomVideoData(customVideoData: customVideoData)

        do {
            try FileHelper.mkdirs(folderCachedCustomVideos)
            let (data, _) = try await URLSession.shared.data(from: url)
            let cachedPathRelative = "\(videoRef.mode_id)_\(videoRef.view_id)_\(videoRef.point_id)_\(videoRef.id).\(url.pathExtension)"
            let cachedURL = FileHelper.file(folderCachedCustomVideos, cachedPathRelative)
            try data.write(to: cachedURL)
            customVideoData.cachedPathRelative = cachedPathRelative
            let image = try await AVAsset(url: url).generateThumbnail()
            let cachedimageURL = FileHelper.file(folderCachedCustomVideos, "\(cachedPathRelative).png")
            let imageData = image!.jpegData(compressionQuality: 1.0)!
            try imageData.write(to: cachedimageURL)
            trySaveLocalData()
            return image
        } catch let error {
            USIM.RemoteLog("Unable to cache video \(videoRef.toString()): \(error)")
            return nil
        }

    }

    public func setVideoToDefault(videoRef: VideoRemoteData) {
        
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
    
    private func getLocalVideoData(_ ref: VideoRemoteData) -> VideoLocalData {
        
        for videoData in localData.videoDatas {
            if(videoData.videoRef == ref) {
                return videoData
            }
        }
        
        let d = VideoLocalData(videoRef: ref)
        localData.videoDatas.append(d)
        return d
    }
    
    public func getMode(modeid: Int) -> ModeDefinition? {
        
        for mode in remoteData.modeDefinitions {
            if(mode.id == modeid) {
                return mode
            }
        }
        for mode in localData.customModeDefinitions {
            if(mode.id == modeid) {
                return mode
            }
        }
        
        return nil
    }
    
    public func isModeNotCustom(modeid: Int) -> Bool {
        
        for mode in remoteData.modeDefinitions {
            if(mode.id == modeid) {
                return true
            }
        }
        
        return false
    }
    
    public func getAccessPointKeyFromCode(code: String) -> Int? {
        
        for pointData in localData.pointDatas {
            if(pointData.code.compare(code) == .orderedSame) {
                for remoteData in remoteData.pointDefinitions {
                    if(remoteData.id == pointData.id) {
                        return pointData.id
                    }
                }
            }
        }
        
        return nil
    }
    
    public func getCachedVideoURLs(point_id: Int, mode_id: Int, view_id: Int) -> [(Int, URL)] {
        
        RemoteLog("Let's try get videos for \(mode_id)_\(view_id)_\(point_id)!")
        
        var videos: [(Int, URL)] = []
        
        for customVideoData in localData.customVideoDatas {
            RemoteLog("Let's check against \(customVideoData.videoRef.mode_id)_\(customVideoData.videoRef.view_id)_\(customVideoData.videoRef.point_id)")
            if(customVideoData.videoRef.point_id == point_id &&
               customVideoData.videoRef.mode_id == mode_id &&
               customVideoData.videoRef.view_id == view_id) {
                RemoteLog("Equal!")
                if let pr = customVideoData.cachedPathRelative {
                    RemoteLog("We have a cached path! \(FileHelper.file(folderCachedCustomVideos, pr).absoluteString)")
                    videos.append((customVideoData.videoRef.id, FileHelper.file(folderCachedCustomVideos, pr)))
                }
            }
        }
        
        for videoData in localData.videoDatas {
            if(videoData.videoRef.point_id == point_id &&
               videoData.videoRef.mode_id == mode_id &&
               videoData.videoRef.view_id == view_id) {
                if let overridePathRelative = videoData.cachedOverridePathRelative {
                    videos.append((videoData.videoRef.id, FileHelper.file(folderCachedCustomVideos, overridePathRelative)))
                }
                if let pathRelative = videoData.cachedPathRelative {
                    videos.append((videoData.videoRef.id, FileHelper.file(folderCachedVideos, pathRelative)))
                }
            }
        }
        
        return videos
    }
    
    public func createCacheVideoUrl(data: CustomVideoData) -> URL? {
        if let pr =  data.cachedPathRelative {
            return FileHelper.file(folderCachedCustomVideos, pr)
        }
        return nil
    }
    
    public func getCachedImage(imageRef: CustomVideoData, cache: NSCache<NSString, UIImage>)  -> UIImage? {
        RemoteLog("Let's try get images for \(imageRef)!")
        if let pr = imageRef.cachedPathRelative {
            RemoteLog("We have a cached path! \(FileHelper.file(folderCachedCustomVideos, pr).absoluteString)")
            
            let imagePath  = FileHelper.file(folderCachedCustomVideos, "\(pr).png").path
            if FileManager.default.fileExists(atPath: imagePath) {
                if let image = cache.object(forKey: imagePath as NSString) {
                    RemoteLog("cached image!")
                    return image
                } else {
                    RemoteLog("uncached image!")
                    let image = UIImage(contentsOfFile: imagePath)
                    cache.setObject(image!, forKey: imagePath as NSString)
                    return image
                }
            }
        }
        return nil
    }
    
    public func getCachedVideoURL(videoRef: VideoRemoteData) -> URL? {
        
        RemoteLog("Let's try get videos for \(videoRef)!")
        
        
        for customVideoData in localData.customVideoDatas {
            RemoteLog("Let's check against \(customVideoData.videoRef.mode_id)_\(customVideoData.videoRef.view_id)_\(customVideoData.videoRef.point_id)")
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
    
    public func addCustomMode(modeid: Int, name: String) {
        
        localData.customModeDefinitions.append(ModeDefinition(id: modeid, name: name))
        trySaveLocalData()
    }
    
    public func addCustomView(modeid: Int, id: Int, name: String) {
        
        localData.customViewDefinitions.append(ViewDefinition(id: id, modeid: modeid, viewname: name))
        trySaveLocalData()
    }
    
    public func getAllCustomMedia(modeid: Int, viewid: Int) -> [CustomVideoData] {
        var datas: [CustomVideoData] = []
        for d in localData.customVideoDatas {
            if(d.videoRef.mode_id == modeid) && (d.videoRef.view_id == viewid)  {
                datas.append(d)
            }
        }
        return datas
    }
    
    public func addCustomVideoData(videoRef: VideoRemoteData, name: String, cachedPathRelative: String?) {
        
        let d = CustomVideoData(videoRef: videoRef, name: name)
        d.cachedPathRelative = cachedPathRelative
        localData.customVideoDatas.append(d)
        trySaveLocalData()
    }
    
    public func deleteCustomMode(modeid: Int) {
        
        localData.customModeDefinitions.removeAll() {
            element in
            return element.id == modeid
        }
        
        localData.customViewDefinitions.removeAll() {
            element in
            return element.modeid == modeid
        }
        
        for d in localData.customVideoDatas {
            if(d.videoRef.mode_id == modeid) {
                uncacheCustomVideoData(customVideoData: d, save: false)
            }
        }
        
        localData.customVideoDatas.removeAll() {
            element in
            return element.videoRef.mode_id == modeid
        }
        
        trySaveLocalData()
    }
    
    public func deleteCustomView(modeid: Int, viewid: Int) {
        
        localData.customViewDefinitions.removeAll() {
            element in
            return element.modeid == modeid && element.id == viewid
        }
        
        for d in localData.customVideoDatas {
            if(d.videoRef.mode_id == modeid && d.videoRef.view_id == viewid) {
                uncacheCustomVideoData(customVideoData: d, save: false)
            }
        }
        
        localData.customVideoDatas.removeAll() {
            element in
            return element.videoRef.mode_id == modeid && element.videoRef.view_id == viewid
        }
        
        trySaveLocalData()
    }
    
    public func getViewIndex(modeKey: Int, viewKey: Int) -> Int? {
        
        var cnt: Int = 0
        for viewDef in remoteData.viewDefinitions {
            if(viewDef.modeid == modeKey) {
                if(viewDef.id == viewKey) {
                    return cnt
                }
                cnt += 1
            }
        }
        for viewDef in localData.customViewDefinitions {
            if(viewDef.modeid == modeKey) {
                if(viewDef.id == viewKey) {
                    return cnt
                }
                cnt += 1
            }
        }
        return nil
    }
    
    public func getAccessPointIndex(pointKey: Int) -> Int? {
        
        var cnt: Int = 0
        
        for p in remoteData.pointDefinitions {
            if(p.id == pointKey) {
                return cnt
            }
            cnt += 1
        }
        
        return nil
    }
    
    public func getCustomVideoDataIndexFromLocalIndex(modeKey: Int, localIndex: Int) -> Int? {
        
        var index = 0
        var cnt = 0
        for d in localData.customVideoDatas {
            if(d.videoRef.mode_id == modeKey) {
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
    
    public func removeCustomVideoData(modeKey: Int, localIndex: Int) {
        
        if let index = getCustomVideoDataIndexFromLocalIndex(modeKey: modeKey, localIndex: localIndex) {
            
            let cvd = localData.customVideoDatas[index]
            uncacheCustomVideoData(customVideoData: cvd, save: false)
            
            localData.customVideoDatas.remove(at: index)
            trySaveLocalData()
        }
    }
    
    public func getDefaultVideos() -> [VideoRemoteData] {
        
        var vids: [VideoRemoteData] = []
        
        for videoData in remoteData.videoRemoteDatas {
            vids.append(videoData)
        }
        
        return vids
    }
    
    public func getVideoInstanceIndex(_ videoRef: VideoRemoteData) -> Int {
        
        var ind = 0
        
        for videoData in remoteData.videoRemoteDatas {
            if(videoData.point_id == videoRef.point_id &&
               videoData.mode_id == videoRef.mode_id &&
               videoData.view_id == videoRef.view_id) {
                if(videoData.id == videoRef.id) {
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
    
    func getUUIDAsInt() -> Int {
        let uuid = UUID()
        let uuidHashValue = uuid.hashValue
        let uuidInt = Int(uuidHashValue) + Int.random(in: 0...999)
        return uuidInt
    }
}
