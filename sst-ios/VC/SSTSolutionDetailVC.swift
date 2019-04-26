//
//  SSTSolutionDetailVC.swift
//  sst-ios
//
//  Created by Amy on 2016/11/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTSolutionDetailVC: SSTBaseVC {

    @IBOutlet weak var webView: UIWebView!
 
    var url = String()
 
    override func viewDidLoad() {
        super.viewDidLoad()

        SSTProgressHUD.show(view: self.view)
        loadWebView(url)
    }

    fileprivate func loadWebView(_ urlStr: String) {
        if let url = URL(string: urlStr) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
}

extension SSTSolutionDetailVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SSTProgressHUD.dismiss(view: self.view)
    }
}
