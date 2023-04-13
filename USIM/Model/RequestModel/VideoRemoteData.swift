//
//  VideoRemoteData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class VideoRemoteData : Codable {
    
    public var videoRef: VideoReference
    public var url: String
    
    init(videoRef: VideoReference, url: URL) {
        self.videoRef = videoRef
        self.url = url.absoluteString
    }
}
