//
//  LicenseViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit

class LicenseViewController: UIViewController {
    
    // MARK: - computed propertiee -
    var isAlert: Bool {
        var isShow: Bool = true
        if (licenseTextField?.text?.count ?? 0) > 0 {
            isShow = false
        } else {
            isShow = true
        }
        return isShow
    }
    
    // MARK: - Properties -
    let licenseRequest = LicenseRequestService()
    
    // MARK: -  IBOutlet -
    @IBOutlet weak var licenseTextField: UITextField? {
        didSet {
            licenseTextField?.text = "test"
        }
    }
    
    // MARK: -  IBAction -
    @IBAction func onClickSubmit(_ sender: LoaderButton) {
        sender.setLoading(true, "Submit")
        if (!isAlert) {
            if let licenseKey = licenseTextField?.text {
                licenseRequest.requestRegisterKey(.registerKey(licenseKey)) {
                    DispatchQueue.main.async {
                        sender.setLoading(false, "Submit")
                        AppLaunchUtilityHelper().showMainTabBar()
                    }
                } errorCompletion: { error in
                    DispatchQueue.main.async {
                        sender.setLoading(false, "Submit")
                        self.showAlert(message: error)
                    }
                }
            }
        } else {
            showAlert(message: "Field cann't be empty")
            sender.setLoading(false, "Submit")
        }
    }
}

