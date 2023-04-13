//
//  LocalData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class LocalData : Codable {
    
    public var customModeDefinitions: [ModeDefinition] = []
    public var customViewDefinitions: [ViewDefinition] = []
    public var videoDatas: [VideoLocalData] = []
    public var pointDatas: [AccessPointLocalData] = []
    public var customVideoDatas: [CustomVideoData] = []
    
    public var license: LicenseInformation? = nil
    
    public func toJSON(encoder: JSONEncoder) throws -> String {
        
        let encoded = try encoder.encode(self)
        return String(data: encoded, encoding: .utf8)!
    }
    
    public static func fromJSON(decoder: JSONDecoder, string: String) throws -> LocalData {
        
        return try decoder.decode(LocalData.self, from: string.data(using: .utf8)!)
    }
}
