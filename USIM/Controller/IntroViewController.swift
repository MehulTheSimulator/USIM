//
//  IntroViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit
import Foundation

class IntroViewController: BaseViewController {
    
    @IBOutlet weak var licenseExpireLabel: UILabel!
    @IBOutlet weak var swipeButton: UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        let licenseInfo = USIM.application.config.getLicenseInfo()
        let licensExpiry = licenseInfo?.endDate.dateFormatting() ?? ""
        licenseExpireLabel.text = "License Expired On This Date \(licensExpiry)"
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGesture.direction = .right
        // Add the gesture recognizer to a view
        swipeButton?.addGestureRecognizer(swipeGesture)
    }
    
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .right:
            guard let controller = configureController(LicenseViewController.self) else { return }
            print("Asher Azeem")
            controller.modalTransitionStyle = .crossDissolve
            controller.modalPresentationStyle = .fullScreen
            present(controller, animated: true)
        default:
            break
        }
    }
}
