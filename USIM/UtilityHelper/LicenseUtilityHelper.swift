//
//  LicenseUtilityHelper.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

public class LicenseRequestService {
    
    func requestRegisterKey(_ endPoint: EndPoints, successCompletion: @escaping ()->Void , errorCompletion: @escaping (String)->Void) {
        Task {
            do {
                let licenseModel =  try await WebServiceManager.requestCallService(endPoint, type: LicenseFormat.self)
                guard licenseModel.success else { errorCompletion(licenseModel.error ?? "")
                    return
                }
                let licensingValue = (endPoint.queryItems.filter({$0.name == "license_key"}).first)?.value ?? ""
                let licenseInfo = LicenseInformation(licenseKey: licensingValue, endDate: licenseModel.expiry ?? Date())
                guard licenseInfo.isValid() else { errorCompletion("The license has expired.")
                    return
                }
                print("License Info ==> \(licenseInfo)")
                USIM.application.config.setLicenseInfo(licenseInfo)
                successCompletion()
            } catch let error {
                errorCompletion(error.localizedDescription)
                return
            }
        }
    }
}
