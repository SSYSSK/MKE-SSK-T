//
//  SSTPaymentVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTPaymentVC: SSTBaseVC {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SSTProgressHUD.show(view: self.view)
        let url = kBaseURLString + "h5/delivery.h5"
        loadWebView(url)
    }
    
    fileprivate func loadWebView(_ urlStr: String) {
        if let url = URL(string: urlStr) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
}

extension SSTPaymentVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SSTProgressHUD.dismiss(view: self.view)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SSTProgressHUD.dismiss(view: self.view)
    }
}
