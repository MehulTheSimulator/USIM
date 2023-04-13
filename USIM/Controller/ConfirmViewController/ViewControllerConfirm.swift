//
//  ViewController.swift
//  RFIDVideoPlayer
//
//  Created by Sagar Haval on 14/09/2022.
//

import UIKit
import AVKit

class ViewControllerConfirm : UIViewController {
    
    @IBOutlet var labelTitle: UILabel!
    @IBOutlet var labelText: UILabel!
    
    public var confirmTitle: String?
    public var confirmText: String?
    public var callback: ((Bool) -> ())?
    
    override var shouldAutorotate: Bool { return false }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .landscape }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .landscapeLeft }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = confirmTitle ?? ""
        labelText.text = confirmText ?? ""
    }
    
    @IBAction func buttonConfirm(_ sender: Any) {
        
        close()
        callback?(true)
    }
    
    @IBAction func buttonCancel(_ sender: Any) {
        
        close()
        callback?(false)
    }
    
    func close() {
        self.dismiss(animated: true)
    }
}

