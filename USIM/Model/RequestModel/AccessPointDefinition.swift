//
//  AccessPointDefinition.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class AccessPointDefinition : Codable {
    
    public var key: String
    public var name: String
    
    init(key: String, name: String) {
        self.key = key
        self.name = name
    }
}

