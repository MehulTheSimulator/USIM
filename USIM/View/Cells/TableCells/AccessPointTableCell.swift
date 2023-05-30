//
//  AccessPointTableCell.swift
//  USIM
//
//  Created by Asher Azeem on 2/17/23.
//

import UIKit

class AccessPointTableCell: UITableViewCell {
    
    // MARK: - Properties -
    weak var target: AccessPointViewController?
    var targetPointKey: Int?

    // MARK: -  IBoutlets -
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var numberLabel: UILabel?
    
    // MARK: -  Configure View -
    @IBAction func onButtonScan(_ sender: Any) {
        target?.scanCode(target: self, pointKey: targetPointKey!)
    }

    public func update() {
        nameLabel?.text =  USIM.application.getAccessPoint(targetPointKey!)?.name ?? ""
        numberLabel?.text = USIM.application.getAccessPointLocalData(targetPointKey!)?.code ?? ""
    }
}
