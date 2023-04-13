//
//  DeleteModePopupViewController.swift
//  USIM
//
//  Created by Asher Azeem on 09/03/2023.
//

import UIKit

class DeleteModePopupViewController: DeleteMediaPopupViewController {
    
    override func doneTapped(sender: UIButton) {
        deleteMediaPopupDelegate?.deleteMode(at: indexPath, modeKey)
    }

}
