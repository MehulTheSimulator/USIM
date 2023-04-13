//
//  WebViewController.swift
//  USIM
//
//  Created by Asher Azeem on 2/18/23.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    // MARK: -  IBOutlets -
    @IBOutlet weak var webView: WKWebView?
    @IBOutlet weak var screenTitleLabel: UILabel?
    
    // MARK: -  Properties -
    var urlString: String = ""
    var screenTitle: String = ""
    
    // MARK: -  Life Cycle -    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        screenTitleLabel?.text = screenTitle
        guard let url = URL(string: urlString) else {
            return
        }
        webView?.load(URLRequest(url: url))
    }
}
