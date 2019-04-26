//
//  SSTOrderShippingInfoCell.swift
//  sst-ios
//
//  Created by Amy on 2017/7/31.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTOrderShippingInfoCell: SSTBaseCell {

    var clickTrackingBlock: ( (_ item: AnyObject) -> Void )?
    
    var nbrsScrollView = loadNib("\(SSTTrackingNbrScrollView.classForCoder())") as! SSTTrackingNbrScrollView
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nbrsScrollView.itemClick = { item in
            self.clickTrackingBlock?(item)
        }
        self.addSubview(nbrsScrollView)
    }
    
    func setData(tranckingNbrs: [SSTShippingInfoVos]) {
        nbrsScrollView.frame = CGRect(x: 110, y: 14, width: kScreenWidth - 110 - kLabelSpaceWidth, height: CGFloat(tranckingNbrs.count) * kOrderTrackingNbrCellNbrHeight)
        nbrsScrollView.setParas(tranckingNbrs, itemWidth: 80, itemHeight: kOrderTrackingNbrCellNbrHeight, placeholder: "")
        nbrsScrollView.scrollView.contentSize = CGSize(width: nbrsScrollView.getItemViewX(tranckingNbrs.count), height: 0)
    }
}

