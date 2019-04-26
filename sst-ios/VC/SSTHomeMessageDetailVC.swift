//
//  SSTHomeMessageDetailVC.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTHomeMessageDetailVC: SSTBaseVC {
    
    var message:SSTMessage?
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(message?.content)
        self.title = "LATEST NEWS"
        titleLabel.text = message?.title

        let contentStr = "<style>img{max-width: "+validString(kScreenWidth-20)+"px;height: auto;}</style>"+(message?.content)!
        
        webView.loadHTMLString(contentStr, baseURL:nil)
        webView.scrollView.bounces = false;
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.showsVerticalScrollIndicator = true
    }
    
}
