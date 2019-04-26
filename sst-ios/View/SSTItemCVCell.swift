//
//  SSTItemCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 7/21/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTItemCVCell: UICollectionViewCell {
    
    let itemV = SSTSearchResultView(frame: CGRect(x: 0, y: 0, width: kSearchResultViewGridWidth, height: kSearchResultViewGridHeight))

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
