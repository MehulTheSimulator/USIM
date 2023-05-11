//
//  toolkit.swift
//  USIM
//
//  Created by mehul on 05/05/2023.
//

import Foundation
import EasyTipView

public class Toolkit: EasyTipViewDelegate{
    
    weak var tipView: EasyTipView?
    var preferences = EasyTipView.globalPreferences
    
    init(tipView: EasyTipView? = nil) {
        self.tipView = tipView
        
        if let tipView = tipView {
            tipView.dismiss(withCompletion: {
                print("Completion called!")
            })
        } else {
            preferences.drawing.foregroundColor = UIColor.white
            preferences.drawing.backgroundColor = UIColor(hue:0.46, saturation:0.99, brightness:0.6, alpha:1)
            preferences.drawing.shadowColor = UIColor.black
            preferences.drawing.shadowRadius = 2
            preferences.drawing.shadowOpacity = 0.75
            preferences.drawing.arrowPosition = EasyTipView.ArrowPosition.top
        }
    }
    
    public func showTipView(sender: UIButton, text: String) {
        
        let tip = EasyTipView(text: text, preferences: preferences, delegate: self)
        tip.show(forView: sender)
    }
    
    public func easyTipViewDidTap(_ tipView: EasyTipView) {
        print("\(tipView) did tap!")
    }
    
    public func easyTipViewDidDismiss(_ tipView: EasyTipView) {
        print("\(tipView) did dismiss!")
    }
    
}
