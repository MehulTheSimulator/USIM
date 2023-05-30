//
//  AccessPointLocalData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class AccessPointLocalData : Codable {
    
    public var id: Int
    public var code: String
    
    init(id: Int, code: String) {
        self.id = id
        self.code = code
    }
}
