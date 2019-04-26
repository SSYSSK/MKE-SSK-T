//
//  SSTHomeItemCVCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/7/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTHomeCategoryItemCVCell: UICollectionViewCell {

    let itemV = SSTHomeCategoryItemCVCellView(frame: CGRect(x: 0, y: 0, width: kSearchResultViewGridWidth, height: kHomeCategoryCellCVCellHeight))

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addSubview(itemV)
    }
    
    var item: SSTItem! {
        didSet {
            itemV.item = item
        }
    }
    
}
