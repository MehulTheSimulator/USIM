//
//  AppLaunchUtilityHelper.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit

class AppLaunchUtilityHelper: UIViewController {
    
    static let share = AppLaunchUtilityHelper()
    
    func showLoginScreen() {
        let loginNavController = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(identifier: String(describing: IntroViewController.self))
        self.loadViewController(loginNavController)
    }
    
    func showMainTabBar() {
        let sideMenuController = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(identifier: String(describing: SideMenuViewController.self))
        self.loadViewController(sideMenuController)
    }
    
    // load view controller
    func loadViewController(_ controller: UIViewController?) {
        SceneDelegate.sceneDelegate.window?.rootViewController = controller
        SceneDelegate.sceneDelegate.window?.makeKeyAndVisible()
    }
}

