//
//  SSTBestSellingCell.swift
//  sst-ios
//
//  Created by Amy on 16/8/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kCartBestSellingCellHeight: CGFloat = kScreenWidth / 2 + 35

class SSTBestSellingCell: UICollectionViewCell {
    
    let itemV = SSTSearchResultView(frame: CGRect(x: 0, y: 0, width:kSearchResultViewGridWidth, height: kCartBestSellingCellHeight))
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(itemV)
    }
    
    var item: SSTItem! {
        didSet {
            itemV.item = item
            
            itemV.addButton.isHidden = true
            itemV.qtyTF.isHidden = true
            itemV.minusButton.isHidden = true
            itemV.soldoutBtn.isHidden = true
            
            itemV.backgroundColor = UIColor.hexStringToColor("#f7f7f7")
        }
    }

}
