//
//  CustomVideoData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class CustomVideoData : Codable {
    
    public var videoRef: VideoRemoteData
    public var name: String
    public var cachedPathRelative: String?
    
    init(videoRef: VideoRemoteData, name: String) {
        self.videoRef = videoRef
        self.name = name
    }
}
