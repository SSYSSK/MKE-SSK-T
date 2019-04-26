//
//  SSTGuideScrollView.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/8/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTGuideScrollView: SSTScrollView {
    
    override func getItemView(_ ind: Int) -> UIView {
        let pageView = loadNib("\(SSTGuidePageView.classForCoder())") as! SSTGuidePageView
        pageView.frame = CGRect(x: CGFloat(ind) * itemWidth, y: 0, width: itemWidth, height: itemHeight)
        pageView.guide = items.validObjectAtIndex(ind) as? SSTGuide
        return pageView
    }

}
