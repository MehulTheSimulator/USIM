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
}
