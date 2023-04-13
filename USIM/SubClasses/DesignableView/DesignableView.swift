//
//  ViewController.swift
//  TheSimulator
//
//  Created by Asher Azeem on 2/3/23.

import UIKit

@IBDesignable public class DesignableView: UIView {
    
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable public var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable public var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }
    
    @IBInspectable public var shadowOffsetX: CGFloat = 0 {
        didSet {
            layer.shadowOffset.width = shadowOffsetX
        }
    }
    
    @IBInspectable public var isRound: Bool = false {
        didSet {
            layer.cornerRadius = isRound ? self.frame.size.height / 2: self.frame.size.height
        }
    }
    
    @IBInspectable var bottomCornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = bottomCornerRadius
            layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            // layer.masksToBounds = true
            // clipsToBounds = true
        }
    }
    
    @IBInspectable var topCornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = topCornerRadius
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
            layer.masksToBounds = true
            clipsToBounds = true
        }
    }
    
    @IBInspectable var leftCornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = leftCornerRadius
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
            layer.masksToBounds = true
            clipsToBounds = true
        }
    }
    
    // MARK: - Dotted Border
    
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        dashBorder.path = cornerRadius > 0 ? UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath : UIBezierPath(rect: bounds).cgPath
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }
}

