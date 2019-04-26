//
//  SSTDealsCell.swift
//  sst-ios
//
//  Created by Amy on 16/8/11.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTDealsCell: SSTItemCVCell {
    
    var indexPath = IndexPath()
    
    override func awakeFromNib() {
        itemV.viewFrom = .fromDeals
        
        super.awakeFromNib()
    }

}
