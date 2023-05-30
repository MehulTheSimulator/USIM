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
    public let endDate: String

    public init(licenseKey: String, endDate: String) {
        self.valid = true
        self.licenseKey = licenseKey
        self.endDate = endDate
    }
    
    public func isValid() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format of the expiry date in your JSON
        guard let expiryDate = dateFormatter.date(from: endDate) else {
            return false
        }
        return Date() < expiryDate
    }

}
