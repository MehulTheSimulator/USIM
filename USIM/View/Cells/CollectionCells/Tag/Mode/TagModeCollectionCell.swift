//
//  TagModeCollectionCell.swift
//  USIM
//
//  Created by Asher Azeem on 2/19/23.
//

import UIKit

class TagModeCollectionCell: UICollectionViewCell {
    
    // MARK: -  IBOutlets -
    @IBOutlet weak var designableView: DesignableView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    // MARK: - Properties -
    weak var target: HomeViewController?
    var isCustom: Bool = false
    var modeKey: Int?
    
    // MARK: - IBActions -
    @IBAction func onButtonSelectMode(_ sender: Any) {
        let app = USIM.application
        if let modeKeyValue = modeKey {
            app.setCurrentMode(modeid: modeKeyValue)
            target?.updateMode()
        }
    }
    
    @IBAction func onButtonEdit(_ sender: Any) {
        target?.editMode(modeKey: modeKey!)
    }
    
    @IBAction func onButtonDelete(_ sender: Any) {
        target?.deleteMode(modeid: modeKey!)
    }
    
    // MARK: - Methods -
    public func update() {
        buttonEdit.isHidden = !isCustom
        buttonDelete?.isHidden = !isCustom
        let app = USIM.application
        button?.setTitle((modeKey != nil ? app.getMode(modeKey: modeKey!)?.name : nil) ?? "", for: .normal)
        designableView.shadowColor = (app.currentMode ?? 0) == modeKey ? UIColor.yellow : UIColor.blue
    }
}
