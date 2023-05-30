//
//  String.swift
//  USIM
//
//  Created by mehul on 09/05/2023.
//

import UIKit

extension String {
    func getVersionAndBuildnumber() -> String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            print("App Version: \(appVersion)")
            print("Build Number: \(buildNumber)")
            return "Version : \(appVersion).\(buildNumber)"
        }
        return ""
    }
    
    func dateFormatting() -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format of the input string date
        guard let date = dateFormatter.date(from: self) else {
            return nil // Return nil if the input string cannot be parsed as a date
        }
        
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let outputString = dateFormatter.string(from: date)
        print(outputString) // Output: "25 August 2023"
        return outputString
    }
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let expiryDate = dateFormatter.date(from: self)
        return expiryDate
    }
}

extension Int {
    func ToString() -> String {
        return String(self)
    }
}
