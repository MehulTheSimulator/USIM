//
//  UpdateConfiguViewController.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit
import MBCircularProgressBar

class UpdateConfiguViewController: UIViewController {
    
    // MARK: - IBOutlets -
    
    @IBOutlet weak var configStatusLabel: UILabel!
    @IBOutlet weak var progressBar: MBCircularProgressBarView!
    @IBOutlet weak var readyButton: LoaderButton!
    
    // MARK: - Properties -
    
    // MARK: - Life Cycle -
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetLoader()
    }
    
    // MARK: - IBActions -
    
    @IBAction func onClickUpdateTool(_ sender: UIButton) {
        let tip = Toolkit()
        tip.showTipView(sender: sender, text: "By updating the configuration, you can stay up-to-date with the latest system updates, including new views, modes, and ultrasound features. This will allow you to use the app more efficiently and effectively.")
    }
    
    @IBAction func onClickUpdate(_ sender: LoaderButton) {
        
        guard Connectivity.isConnectedToNetwork() else{
            if let url = URL(string: UIApplication.openSettingsURLString) {
                if !UIApplication.shared.canOpenURL(url) {
                    return
                }
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            return
        }
        sender.setLoading(true, "Ready")
        Task {
            do {
                try await USIM.application.config.updateRemoteConfigAsync(
                    statusCompletion: { state in
                        USIM.RemoteLog("State: \(state)")
                        self.configStatusLabel.text = state
                    }, percentageCompletion: { percentage in
                        let per = CGFloat(percentage)
                        self.progressBar.value = (per * 100.0)
                        if percentage == 1.0 {
                            self.resetLoader(title: "Updated", percentage: per * 100)
                        }
                    })
                USIM.application.currentMode = USIM.application.config.getDefaultMode()
                if let cmode = USIM.application.currentMode {
                    USIM.application.currentView = USIM.application.config.getDefaultView(modeid: cmode)
                }
            } catch let error {
                USIM.RemoteLog("ERROR: \(error)")
                showAlert(message: error.localizedDescription)
                resetLoader(title: "Try Again")
            }
        }
    }
    
    func resetLoader(title: String = "Ready", percentage: CGFloat = 0) {
        readyButton.setLoading(false, title)
        resetConfig(percentage)
    }
    
    func resetConfig(_ percentage: CGFloat) {
        self.configStatusLabel?.text = ""
        self.progressBar.value = percentage
    }
}
