//
//  ViewDefinition.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class ViewDefinition : Codable {
    
    public var key: String
    public var modeKey: String
    public var name: String
    
    init(key: String, modeKey: String, name: String) {
        self.key = key
        self.modeKey = modeKey
        self.name = name
    }
}
