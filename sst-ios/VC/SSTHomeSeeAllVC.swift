//
//  SSTHomeSeeAllVC.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/3.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTHomeSeeAllVC: SSTBaseItemsVC {
    
    var homeSeeAll: HomeSeeAllType!
    
    @IBOutlet weak var itemButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollViewFrameHeight = kScreenHeight - kScreenNavigationHeight - kScreenTabbarHeight
        
        if homeSeeAll == .newArrival {
            self.title = HomeSeeAllType.newArrival.rawValue
        } else if homeSeeAll == .featureProducts {
            self.title = HomeSeeAllType.featureProducts.rawValue
        }
        
        SSTProgressHUD.show(view: self.view)
        fetchItems()
    }

    override func fetchItems(start: Int? = 0) {
        if homeSeeAll == .newArrival {
            itemData.getNewArrivals()
        } else if homeSeeAll == .featureProducts {
            itemData.getFeaturedProduct()
        }
    }
    
    override func setStyleImage() {
        if layoutStyle == .grid {
            itemButton.image = UIImage(named: kStyleListImageName)
        } else {
            itemButton.image = UIImage(named: kStyleGridImageName)
        }
    }
    
    @IBAction func clickedStyleButton(_ sender: AnyObject) {
        self.updateItemViewStyle()
    }
}

