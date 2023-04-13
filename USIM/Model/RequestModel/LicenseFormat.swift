//
//  LicenseFormat.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class LicenseFormat: Codable {
    public let success: Bool
    public let error: String?
    public let expiry: Date?
}

