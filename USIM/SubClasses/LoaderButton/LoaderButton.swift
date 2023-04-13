//
//  LoaderButton.swift
//  USIM
//
//  Created by Asher Azeem on 04/03/2023.
//

import UIKit

class LoaderButton: UIButton {
    
    let loader = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit()  {
        loader.hidesWhenStopped = true
        loader.style = .medium
        self.addSubview(loader)
        loader.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loader.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            loader.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    func setLoading(_ loading: Bool, _ title: String, color: UIColor = UIColor.white) {
        loader.color = color
        isUserInteractionEnabled = !loading
        setTitle(loading ? nil : title, for: .normal)
        loading ? loader.startAnimating() : loader.stopAnimating()
    }
}
