//
//  EndPoints.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public struct EndPoints {
    let path: String
    let queryItems: [URLQueryItem]
}

extension EndPoints {
    
    static func registerKey(_ licenseKey: String) -> EndPoints {
        return EndPoints(
            path: "/license_check.php",
            queryItems: [
                URLQueryItem(name: "device_id", value: UIDevice.userID ?? ""),
                URLQueryItem(name: "license_key", value: licenseKey)
            ]
        )
    }
    
    static func remoteLog(_ text: String) -> EndPoints {
        return EndPoints(
            path: "/log.php",
            queryItems: [
                URLQueryItem(name: "log_text", value: "\(Int64((Date().timeIntervalSince1970 * 1000.0).rounded())): \(text)"),
            ]
        )
    }
    
    static func cachVideo() -> (String,[String:String]) {
        return ("https://thesimulatorcompanysecure.com/video_upload.php",["password": "Team-TSC"])
    }
}

extension EndPoints {
    // We still have to keep 'url' as an optional, since we're
    // dealing with dynamic components that could be invalid.
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "thesimulatorcompanysecure.com"
        components.path = path
        components.queryItems = queryItems
        print(components.url)
        return components.url
    }
}
