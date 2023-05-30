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
                guard licenseModel.hasError else { errorCompletion(licenseModel.message)
                    return
                }
                let licenseInfo = LicenseInformation(licenseKey: licenseModel.view?.licenseKey ?? "", endDate: licenseModel.view?.expiryDate ?? "")
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
