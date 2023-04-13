//
//  RemoteData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class RemoteData : Codable {
    
    public var modeDefinitions: [ModeDefinition] = []
    public var viewDefinitions: [ViewDefinition] = []
    public var pointDefinitions: [AccessPointDefinition] = []
    public var videoRemoteDatas: [VideoRemoteData] = []
    
    public func toJSON(encoder: JSONEncoder) throws -> String {
        
        let encoded = try encoder.encode(self)
        return String(data: encoded, encoding: .utf8)!
    }
    
    public static func fromJSON(decoder: JSONDecoder, string: String) throws -> RemoteData {
        
        return try decoder.decode(RemoteData.self, from: string.data(using: .utf8)!)
    }
}

