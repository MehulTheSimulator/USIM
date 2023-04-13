//
//  Application.swift
//  RFIDVideoPlayer
//
//  Created by Sagar Haval on 29/09/2022.
//

import Foundation

public class Application {

    public let config: ApplicationConfig

    public var currentMode: String?
    public var currentView: String?
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
            currentView = config.getDefaultView(modeKey: cmode)
        }
        config.debugPrint()
    }

    public func isValidMode(modeKey: String) -> Bool {

        return config.getMode(modeKey: modeKey) != nil
    }

    public func setCurrentMode(modeKey: String) {

        if(!isValidMode(modeKey: modeKey)) {
            return
        }

        currentMode = modeKey
        currentView = config.getDefaultView(modeKey: currentMode!)
    }

    public func isValidView(modeKey: String, viewKey: String) -> Bool {

        return config.getViewDefinition(modeKey: modeKey, viewKey: viewKey) != nil
    }

    public func setCurrentView(modeKey: String, viewKey: String) {

        if(!isValidMode(modeKey: modeKey) || !isValidView(modeKey: modeKey, viewKey: viewKey)) {
            return
        }

        currentView = viewKey
    }

    public func getMode(modeKey: String) -> ModeDefinition? {

        return config.getMode(modeKey: modeKey)
    }

    public func getMode(_ index: Int) -> ModeDefinition? {

        return config.getMode(index: index)
    }

    public func getAccessPointCount() -> Int {

        return config.getAccessPointCount()
    }

    public func getAccessPoint(_ index: Int) -> AccessPointDefinition? {
        return config.getAccessPoint(index: index)
    }

    public func getAccessPoint(_ key: String) -> AccessPointDefinition? {
        return config.getAccessPoint(key: key)
    }

    public func getAccessPointLocalData(_ key: String) -> AccessPointLocalData? {
        return config.getAccessPointLocalData(key: key)
    }

    public func setAccessPointCode(_ key: String, _ code: String) {
        config.setAccessPointCode(key: key, code: code)
    }

    public func setVideoToDefault(_ videoRef: VideoReference) {
        config.setVideoToDefault(videoRef: videoRef)
    }

    /*public func setCustomVideoURL(_ videoRef: VideoReference, _ url: URL) async {

     await config.setCustomVideoURL(videoRef: videoRef, url: url)
     }**/

    public func getCachedVideoURLsForCode(code: String) -> [(String, URL)] {

        guard let modeKey = currentMode else {
            return []
        }

        guard let viewKey = currentView else {
            return []
        }

        guard let pointKey = config.getAccessPointKeyFromCode(code: code) else {
            return []
        }

        return config.getCachedVideoURLs(pointKey: pointKey, modeKey: modeKey, viewKey: viewKey)
    }

    public func isLicenseValid() -> Bool {

        return config.getLicenseInfo()?.isValid() ?? false
    }
}

public let application: Application = Application()

