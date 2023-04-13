//
//  ViewController.swift
//  RFIDVideoPlayer
//
//  Created by Sagar Haval on 14/09/2022.
//

import UIKit
import AVKit

class ViewControllerEditView : UIViewController {
    
    // MARK: - IBOutlets -
    @IBOutlet var textFieldName: UITextField!
    
    // MARK: - Properties -
    public var targetModeKey: String?
    public var targetViewKey: String?
    
    // MARK: - IBActions -
    @IBAction func buttonSetNamePressed(_ sender: Any) {
        if let def = USIM.application.config.getViewDefinition(modeKey: targetModeKey!, viewKey: targetViewKey!) {
            def.name = textFieldName.text ?? "New View"
            USIM.application.config.trySaveLocalData()
        }
        goToVideoPlayer()
    }
    
    @IBAction func buttonBackPressed(_ sender: Any) {
        goToVideoPlayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldName.text = USIM.application.config.getViewDefinition(modeKey: targetModeKey!, viewKey: targetViewKey!)?.name ?? ""
    }
    
    func goToVideoPlayer() {
        self.dismiss(animated: true)
    }
}

