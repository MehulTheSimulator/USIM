//
//  DeleteMediaPopupViewController.swift
//  USIM
//
//  Created by Asher Azeem on 23/02/2023.
//

import UIKit

protocol DeleteMediaPopupDelegate {
    func deleteMode(at index: IndexPath?, _ modeKey: String?)
    func deleteView(at index: IndexPath?, _ modeKey: String?, _ viewKey: String?)
}

class DeleteMediaPopupViewController: PopupBaseViewController {
    
    // MARK: - Properties -
    var deleteMediaPopupDelegate: DeleteMediaPopupDelegate?
    var indexPath: IndexPath?
    var modeKey: String?
    var viewKey: String?
    
}
