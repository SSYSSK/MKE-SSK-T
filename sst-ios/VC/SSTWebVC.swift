//
//  SSTWebVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/5/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTWebVC: SSTBaseVC, UIWebViewDelegate {
    
    var webTitle: String?
    var webUrl: String?
    var webHtmlString: String?
    
    var msgId: String?

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if webTitle != nil {
            self.title = webTitle
        }
        
        if webUrl != nil {
            if let url = URL(string: webUrl!) {
                SSTProgressHUD.show(view: self.view)
                webView.loadRequest(URLRequest(url: url))
            }
        } else if webHtmlString != nil {
            webView.loadHTMLString(validString(webHtmlString), baseURL: nil)
        } else if msgId != nil {
            SSTProgressHUD.show(view: self.view)
            SSTMessageData().fetchMessage(msgId: validString(msgId), callback: { (data, error) in
                SSTProgressHUD.dismiss(view: self.view)
                if error == nil, let msg = data as? SSTMessage {
                    self.title = msg.title
                    self.webView.loadHTMLString("<font size='13px'>\(validString(msg.content))</font>", baseURL: nil)
                }
            })
        }
    }
    
    // MARK: -- UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SSTProgressHUD.dismiss(view: self.view)
    }
}
