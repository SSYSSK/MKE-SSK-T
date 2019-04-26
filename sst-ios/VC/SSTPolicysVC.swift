//
//  SSTPolicysVC.swift
//  sst-ios
//
//  Created by Amy on 16/8/24.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTPolicysVC: SSTBaseVC {

    @IBOutlet weak var webView: UIWebView!
    
    var url = String()
    var titleName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleName
        SSTProgressHUD.show(view: self.view)
        loadWebView(url)
    }

    fileprivate func loadWebView(_ urlStr: String) {
        if let url = URL(string: urlStr) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension SSTPolicysVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SSTProgressHUD.dismiss(view: self.view)
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SSTProgressHUD.dismiss(view: self.view)
    }
}
