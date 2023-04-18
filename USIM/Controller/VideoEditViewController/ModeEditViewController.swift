//
//  ModeEditViewController.swift
//  USIM
//
//  Created by mehul on 17/04/2023.
//

import UIKit

class ModeEditViewController: UIViewController {
    // MARK: - IBOutlets -
    @IBOutlet weak var txtMode: UITextField!
    
    // MARK: - Properties -
    public var targetModeKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtMode?.text = USIM.application.getMode(modeKey: targetModeKey!)?.name
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        goToVideoPlayer()
    }
    
    @IBAction func btnSave(_ sender: UIButton) {
        if let def = USIM.application.getMode(modeKey: targetModeKey!) {
            def.name = txtMode?.text ?? "New Mode"
            USIM.application.config.trySaveLocalData()
        }
        goToVideoPlayer()
    }
    
    func goToVideoPlayer() {
        self.dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}