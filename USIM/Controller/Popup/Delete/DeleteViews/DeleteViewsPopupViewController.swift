//
//  DeleteViewsPopupViewController.swift
//  USIM
//
//  Created by Asher Azeem on 09/03/2023.
//

import UIKit

class DeleteViewsPopupViewController: DeleteMediaPopupViewController {
    
    override func doneTapped(sender: UIButton) {
        deleteMediaPopupDelegate?.deleteView(at: indexPath, modeKey, viewKey)
    }
    
}
