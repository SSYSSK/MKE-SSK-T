//
//  SSTHomeDailyDealsCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/3/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTHomeDailyDealsView: SSTScrollView {
    
    var seeAllClick: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func getItemView(_ ind: Int) -> UIView {
        let itemV = loadNib("\(SSTHomeDailyDealsItemV.classForCoder())") as! SSTHomeDailyDealsItemV
        itemV.frame = CGRect(x: CGFloat(ind) * itemWidth, y: 0, width: kHomeDailyDealsCellWidth, height: kHomeDailyDealsCellHeight)
        if let tItem = items.validObjectAtIndex(ind) as? SSTItem {
            itemV.item = tItem
        }
        return itemV
    }
    
    @IBAction func seeAllEvent(_ sender: AnyObject) {
        seeAllClick?()
    }
}
