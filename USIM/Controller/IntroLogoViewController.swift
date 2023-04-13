//
//  IntroLogoViewController.swift
//  USIM
//
//  Created by Asher Azeem on 25/02/2023.
//

import UIKit
import SDWebImage

class IntroLogoViewController: UIViewController {
    
    // MARK: - Properties -
    
    @IBOutlet weak var logoImage: UIImageView?
    
    // MARK: - Life Cycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage?.loadGifFile(with: "USIMLogoAnimatiton")
        Timer.scheduledTimer(withTimeInterval: 6.0, repeats: false) { timer in
            timer.invalidate()
            USIM.application.isLicenseValid() ? self.goToHomeScreen() : self.goToIntroScreen()
        }
    }
    
//    func goToIntroScreen() {
//        AppLaunchUtilityHelper().showLoginScreen()
//    }
//
//    func goToHomeScreen()  {
//        AppLaunchUtilityHelper().showMainTabBar()
//    }
    
    func goToHomeScreen() {
        let controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(identifier: String(describing: SideMenuViewController.self)) as! SideMenuViewController
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
    
    func goToIntroScreen() {
        let controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(identifier: String(describing: IntroViewController.self)) as! IntroViewController
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false, completion: nil)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        USIM.RemoteLog("Press Videoplayer: \(presses)")
        let didHandleEvent = USIM.inputManager.pressesEnded(presses, with: event)
        if didHandleEvent == false {
            // Didn't handle this key press, so pass the event to the next responder.
            super.pressesBegan(presses, with: event)
        }
    }
}

