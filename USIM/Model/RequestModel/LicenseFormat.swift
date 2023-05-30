//
//  LicenseFormat.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

/*
public class LicenseFormat: Codable {
    public let success: Bool
    public let error: String?
    public let expiry: Date?
}*/

struct LicenseFormat: Codable {
    let statusCode: String
    let message: String
    let hasError: Bool
    let view: ViewData?
    
    struct ViewData: Codable {
        let id: Int
        let name: String
        let licenseKey: String
        let registeredDeviceId: String
        let company: String
        let contactEmail: String
        let contactNumber: String
        let expiryDate: String
        let deletedAt: String?
        
        enum CodingKeys: String, CodingKey {
            case id, name, company
            case licenseKey = "license_key"
            case registeredDeviceId = "registered_device_id"
            case contactEmail = "contact_email"
            case contactNumber = "contact_number"
            case expiryDate = "expiry_date"
            case deletedAt = "deleted_at"
        }
    }
}
