//
//  SSTBaseNavigationController.swift
//  sst-mobile
//
//  Created by Amy on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit

let kNavigationBarForegroundColor = RGBA(66, g: 68, b: 151, a: 1)
let kNavigationBarFont = UIFont.boldSystemFont(ofSize: 16)

class SSTBaseNC: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationBar.setBackgroundImage(getNavigationBarBgImage(), for: UIBarMetrics.default)
        
        self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: kNavigationBarForegroundColor, NSAttributedStringKey.font: kNavigationBarFont]
    }
}

