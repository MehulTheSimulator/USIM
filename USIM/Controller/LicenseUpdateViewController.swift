//
//  LicenseUpdateViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit

class LicenseUpdateViewController: UIViewController {
    
    // MARK: - Lazy Properties
    // MARK: - IBOutlets -
    
    @IBOutlet weak var validLicenseLabel: UILabel?
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let licenseInfo = USIM.application.config.getLicenseInfo()
        let licensExpiry = licenseInfo?.endDate.dateFormatting() ?? ""
        validLicenseLabel?.text = "License Valid - \(licensExpiry)"
    }
    
    @IBAction func onClickLicenseTool(_ sender: UIButton) {
        let tip = Toolkit()
        tip.showTipView(sender: sender, text: "This section allows you to manage your license. You can view the expiration date of your license key, and if it is nearing expiration, you can contact us to renew it.")
    }
}
