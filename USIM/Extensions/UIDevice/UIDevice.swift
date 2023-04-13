//
//  UIDevice.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

extension UIDevice {
    
    static var userID: String? {
        UIDevice.current.identifierForVendor?.uuidString
    }
    
}
