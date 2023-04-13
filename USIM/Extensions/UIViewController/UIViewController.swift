//
//  UIViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit

extension UIViewController {
    
    func configureController(_ name: AnyClass) -> UIViewController? {
        return storyboard?.instantiateViewController(withIdentifier: String(describing: name.self))
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
