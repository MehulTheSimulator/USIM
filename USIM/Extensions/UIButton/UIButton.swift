//
//  UIButton.swift
//  USIM
//
//  Created by Asher Azeem on 2/15/23.
//

import Foundation
import UIKit

extension UIButton {
    // round conrer
    @IBInspectable var customRoundCorner: Bool {
        set {
            newValue ? (self.layer.cornerRadius = self.frame.size.height / 2) : (self.layer.cornerRadius = self.frame.size.height)
        } get {
            return self.customRoundCorner
        }
    }
    
    // border width
    @IBInspectable var customBorderWidth: CGFloat {
        set {
            self.layer.borderWidth = newValue
        } get {
            return self.customBorderWidth
        }
    }
    
    // border color
    @IBInspectable var customBorderColor: UIColor {
        set {
            self.layer.borderColor = newValue.cgColor
        } get {
            return self.customBorderColor
        }
    }
    
    @IBInspectable public var borderRadius: CGFloat {
        set {
            self.layer.cornerRadius = newValue
        } get {
            self.borderRadius
        }
    }
}
