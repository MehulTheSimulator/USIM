//
//  LicenseModel.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class LicenseInformation: Codable {
    
    public let valid: Bool
    public let licenseKey: String
    public let endDate: Date

    public init(licenseKey: String, endDate: Date) {
        self.valid = true
        self.licenseKey = licenseKey
        self.endDate = endDate
    }

    public func isValid() -> Bool {
        return valid && Date() < endDate
    }
}
