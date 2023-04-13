//
//  VideoReference.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class VideoReference : Hashable, Codable {
    
    public let modeKey: String
    public let viewKey: String
    public let pointKey: String
    public let instanceKey: String
    
    init(modeKey: String, viewKey: String, pointKey: String, instanceKey: String) {
        self.modeKey = modeKey
        self.viewKey = viewKey
        self.pointKey = pointKey
        self.instanceKey = instanceKey
    }
    
    public func toString() -> String {
        return "[\(modeKey), \(viewKey), \(pointKey), \(instanceKey)]"
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.modeKey)
        hasher.combine(self.viewKey)
        hasher.combine(self.pointKey)
        hasher.combine(self.instanceKey)
    }
    
    public static func ==(lhs: VideoReference, rhs: VideoReference) -> Bool {
        return lhs.modeKey.compare(rhs.modeKey) == .orderedSame && lhs.viewKey.compare(rhs.viewKey) == .orderedSame && lhs.pointKey.compare(rhs.pointKey) == .orderedSame && lhs.instanceKey.compare(rhs.instanceKey) == .orderedSame
    }
}
