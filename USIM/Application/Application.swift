//
//  Application.swift
//  RFIDVideoPlayer
//
//  Created by Sagar Haval on 29/09/2022.
//

import Foundation

public class Application {

    public let config: ApplicationConfig

    public var currentMode: Int?
    public var currentView: Int?
    //public var videoDefinitions = [VideoDefinition]()

    init() {
        config = ApplicationConfig()
    }

    public func initApp() {
        /*Task {
         [self] in
         //await config.initDummyData()
         do {
         try await config.updateRemoteConfigAsync({ status in }, { percentage in })
         } catch let error {
         print("UPDATE ERROR: \(error)")
         }
         }*/
        currentMode = config.getDefaultMode()
        if let cmode = currentMode {
            currentView = config.getDefaultView(modeid: cmode)
        }
        config.debugPrint()
    }

    public func isValidMode(modeid: Int) -> Bool {

        return config.getMode(modeid: modeid) != nil
    }

    public func setCurrentMode(modeid: Int) {

        if(!isValidMode(modeid: modeid)) {
            return
        }

        currentMode = modeid
        currentView = config.getDefaultView(modeid: currentMode!)
    }

    public func isValidView(modeid: Int, viewid: Int) -> Bool {

        return config.getViewDefinition(modeid: modeid, viewid: viewid) != nil
    }

    public func setCurrentView(modeid: Int, viewid: Int) {

        if(!isValidMode(modeid: modeid) || !isValidView(modeid: modeid, viewid: viewid)) {
            return
        }

        currentView = viewid
    }

    public func getMode(modeKey: Int) -> ModeDefinition? {
        return config.getMode(modeid: modeKey)
    }

    public func getMode(_ index: Int) -> ModeDefinition? {
        return config.getMode(index: index)
    }

    public func getAccessPointCount() -> Int {
        return config.getAccessPointCount()
    }

    public func getAccessPointByIndex(_ index: Int) -> AccessPointDefinition? {
        return config.getAccessPoint(index: index)
    }

    public func getAccessPoint(_ id: Int) -> AccessPointDefinition? {
        return config.getAccessPoint(id: id)
    }

    public func getAccessPointLocalData(_ id: Int) -> AccessPointLocalData? {
        return config.getAccessPointLocalData(id: id)
    }

    public func setAccessPointCode(_ id: Int, _ code: String) {
        config.setAccessPointCode(id: id, code: code)
    }

    public func setVideoToDefault(_ videoRef: VideoRemoteData) {
        config.setVideoToDefault(videoRef: videoRef)
    }

    /*public func setCustomVideoURL(_ videoRef: VideoReference, _ url: URL) async {

     await config.setCustomVideoURL(videoRef: videoRef, url: url)
     }**/

    public func getCachedVideoURLsForCode(code: String) -> [(Int, URL)] {

        guard let modeKey = currentMode else {
            return []
        }

        guard let viewKey = currentView else {
            return []
        }

        guard let pointKey = config.getAccessPointKeyFromCode(code: code) else {
            return []
        }

        return config.getCachedVideoURLs(point_id: pointKey, mode_id: modeKey, view_id: viewKey)
    }

    public func isLicenseValid() -> Bool {

        return config.getLicenseInfo()?.isValid() ?? false
    }
}

public let application: Application = Application()

