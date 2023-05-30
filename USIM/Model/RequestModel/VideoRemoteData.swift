//
//  VideoRemoteData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class VideoRemoteData : Codable, Hashable {
    
    public var url: String?
    public let point_id: Int
    public let mode_id: Int
    public let view_id: Int
    public let id: Int
    
    init(url: URL?, mode_id: Int, view_id: Int, point_id: Int, id: Int) {
        self.url = url?.absoluteString
        self.mode_id = mode_id
        self.view_id = view_id
        self.point_id = point_id
        self.id = id
    }
    
    public func toString() -> String {
        return "[\(mode_id), \(view_id), \(point_id), \(id)]"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.mode_id)
        hasher.combine(self.view_id)
        hasher.combine(self.point_id)
        hasher.combine(self.id)
    }
    
    public static func ==(lhs: VideoRemoteData, rhs: VideoRemoteData) -> Bool {
        return lhs.mode_id == rhs.mode_id && lhs.view_id == rhs.view_id && lhs.point_id == rhs.point_id && lhs.id == rhs.id
    }
}
