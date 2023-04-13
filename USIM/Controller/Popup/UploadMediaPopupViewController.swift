//
//  UploadMediaPopupViewController.swift
//  USIM
//
//  Created by Asher Azeem on 23/02/2023.
//

import UIKit
import SwiftPopup

protocol UploadMediaPopupDelegate {
    func confirmed()
}


class UploadMediaPopupViewController: PopupBaseViewController  {
    
    // MARK: - Properties -
    var uploadMediaPopupDelegate: UploadMediaPopupDelegate?
        
    // MARK: - IBActions -
    override func doneTapped(sender: UIButton) {
        self.uploadMediaPopupDelegate?.confirmed()
    }
}
