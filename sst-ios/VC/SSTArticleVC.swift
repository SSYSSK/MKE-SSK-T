//
//  SSTArticleVC.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/1/18.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTArticleVC: SSTBaseVC {
    
    var articleId: String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        SSTProgressHUD.show(view: self.view)
        SSTArticle.fetchArticle(id: validString(articleId)) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil, let article = data as? SSTArticle {
                self.webView.loadHTMLString(validString(article.content), baseURL: nil)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }

}
