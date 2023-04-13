//
//  TagViewsCollectionCell.swift
//  USIM
//
//  Created by Asher Azeem on 05/03/2023.
//

import UIKit

class TagViewsCollectionCell: UICollectionViewCell {
    
    
    // MARK: -  IBOutlets -
    @IBOutlet weak var designableView: DesignableView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonEdit: UIButton!
    @IBOutlet weak var buttonDelete: UIButton!
    
    // MARK: - properties -
    weak var target: HomeViewController?
    var isCustom: Bool = false
    var modeKey: String?
    var viewKey: String?
    
    // MARK: - IBActions -
    @IBAction func onButtonSelectMode(_ sender: Any) {
        if let modeKeyValue = modeKey {
            if let viewKeyValue = viewKey {
                USIM.application.setCurrentView(modeKey: modeKeyValue, viewKey: viewKeyValue)
                target?.updateView()
            }
        }
    }
    
    @IBAction func onButtonEdit(_ sender: Any) {
        target?.editView(modeKey: modeKey!, viewKey: viewKey!)
    }
    
    @IBAction func onButtonDelete(_ sender: Any) {
        target?.deleteView(modeKey: modeKey!, viewKey: viewKey!)
    }
    
    // MARK: -  Methods -
    public func update() {
        buttonEdit?.isHidden = !isCustom
        buttonDelete?.isHidden = !isCustom
        button?.setTitle((modeKey != nil && viewKey != nil ? USIM.application.config.getViewDefinition(modeKey: modeKey!, viewKey: viewKey!)?.name : nil) ?? "", for: .normal)
        designableView.shadowColor = (USIM.application.currentView ?? "") == viewKey ? UIColor.blue : UIColor.yellow
    }
}
