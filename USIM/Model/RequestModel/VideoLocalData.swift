//
//  VideoLocalData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class VideoLocalData : Codable {
    
    public var videoRef: VideoReference
    public var cachedPathRelative: String?
    public var cachedOverridePathRelative: String?
    
    init(videoRef: VideoReference) {
        self.videoRef = videoRef
    }
}
