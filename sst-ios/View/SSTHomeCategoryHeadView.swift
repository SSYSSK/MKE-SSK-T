//
//  SSTHomeItemsCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/6/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kHomeCategoryCellCVCellHeight = kScreenWidth / 2 + 15

class SSTHomeCategoryHeadView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seeAllButton: UIButton!
    
    func setTitle(_ title: String) {
        self.titleLabel.text = title
    }
    
    var sellAllClick:(() -> Void)?
    
    @IBAction func selAllEvent(_ sender: AnyObject) {
        sellAllClick?()
    }
}
