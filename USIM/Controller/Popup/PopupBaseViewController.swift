//
//  PopupBaseViewController.swift
//  USIM
//
//  Created by Asher Azeem on 23/02/2023.
//

import UIKit
import SwiftPopup

class PopupBaseViewController: SwiftPopup {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var detailTextView: UITextView?
    @IBOutlet weak var popupTitle: UILabel?
    
    // MARK: - IBActions -
    @IBAction func onClickDone(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.doneTapped(sender: sender)
        }
    }
    
    @IBAction func onClickCancel(_ sender: UIButton) {
        dismissPopup()
    }
    
    // MARK: - Methods -
    func dismissPopup() {
        dismiss {}
    }
    
    func doneTapped(sender: UIButton) {
        // override according to screena
    }
}
