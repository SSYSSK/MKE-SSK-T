//
//  SSTMainTabbarController.swift
//  sst-mobile
//
//  Created by Amy on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit

class SSTMainTC: UITabBarController, SSTCartBadgeValueDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor:UIColor.colorWithCustom(142, g: 144, b: 243)], for: UIControlState.selected)
        
        gMainTC = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshUI()
        biz.cart.badgeValueDelegate = self
    }
    
    func refreshUI() {
        if biz.cart.qty > 0 {
            self.childViewControllers[TabIndexType.cart.rawValue].tabBarItem.badgeValue = validString(biz.cart.qty)
            self.childViewControllers[TabIndexType.cart.rawValue].tabBarItem.title = biz.cart.orderItemsTotal.formatC()
        } else {
            self.childViewControllers[TabIndexType.cart.rawValue].tabBarItem.badgeValue = nil
            self.childViewControllers[TabIndexType.cart.rawValue].tabBarItem.title = "Cart"
        }
    }
}
