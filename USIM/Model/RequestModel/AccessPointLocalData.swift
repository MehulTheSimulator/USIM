//
//  AccessPointLocalData.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class AccessPointLocalData : Codable {
    
    public var key: String
    public var code: String
    
    init(key: String, code: String) {
        self.key = key
        self.code = code
    }
}
