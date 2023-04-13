//
//  CustomVideoData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class CustomVideoData : Codable {
    
    public var videoRef: VideoReference
    public var name: String
    public var cachedPathRelative: String?
    
    init(videoRef: VideoReference, name: String) {
        self.videoRef = videoRef
        self.name = name
    }
}
