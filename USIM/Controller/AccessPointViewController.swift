//
//  AccessPointViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/17/23.
//

import UIKit

class AccessPointViewController: UIViewController {
    
    // MARK: -  IBOutlets -
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var labelState: UILabel!
    
    // MARK: - Properties -
    var targetPointKey: String?
    weak var targetCell: AccessPointTableCell? = nil

    // MARK: - Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        labelState?.text = ""
        targetPointKey = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView?.reloadData()
        USIM.inputManager.resetInput()
        USIM.inputManager.setCallback(self)
        USIM.RemoteLog("Set Input Handler to \(self)")
    }
    
    @IBAction func onClickAccessPointsTool(_ sender: UIButton) {
        let tip = Toolkit()
        tip.showTipView(sender: sender, text: "Here allows you to connect to Maicon's access points using a probe scan, and also provides a list of access points that can be easily modified as needed.")
    }
    
    // MARK: - Methods -
    func scanCode(target: AccessPointTableCell, pointKey: String) {
        labelState?.text = "Scanning code for \(USIM.application.getAccessPoint(pointKey)!.name)"
        USIM.inputManager.resetInput()
        targetCell = target
        targetPointKey = pointKey
        USIM.RemoteLog("TargetPointKey: \(targetPointKey ?? "Unset")")
    }
}

// MARK: -  UITableViewDelegate, UITableViewDataSource
extension AccessPointViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return USIM.application.getAccessPointCount()
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccessPointTableCell.self), for: indexPath) as! AccessPointTableCell
        cell.target = self
        let accessPoint = USIM.application.getAccessPoint(indexPath.row)!
        cell.targetPointKey = accessPoint.key
        RemoteLog("Cell TargetPointKey: \(cell.targetPointKey ?? "Unset")")
        cell.update()
        return cell
    }
}

// MARK: - RFIDInputHandlerCallback
extension AccessPointViewController: RFIDInputHandlerCallback {
    func handleValidInput(input: String) {
        USIM.RemoteLog("TargetPointKey: \(targetPointKey ?? "Unset")")
        if let tpk = targetPointKey {
            USIM.application.setAccessPointCode(tpk, input)
            USIM.RemoteLog("Set \(tpk) to \(input)")
            USIM.RemoteLog("New value of \(tpk): \(USIM.application.getAccessPointLocalData(targetPointKey!)?.code ?? "")")
            labelState?.text = "Scanned!"
            tableView?.reloadData()
        }
        targetPointKey = nil
        targetCell = nil
    }
}
