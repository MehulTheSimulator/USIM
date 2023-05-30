//
//  ModeDefinition.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class ModeDefinition : Codable {
    
    public var id: Int
    public var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}
