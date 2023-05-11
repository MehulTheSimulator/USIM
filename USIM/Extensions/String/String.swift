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
}
