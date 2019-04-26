//
//  SSTTrackingNbrScrollView.swift
//  sst-ios
//
//  Created by Zal Zhang on 8/2/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTTrackingNbrScrollView: SSTScrollView {
    
    func getItemViewX(_ ind: Int) -> CGFloat {
        var originX: CGFloat = 0
        for iii in 0 ..< ind {
            if let trackingNbr = items.validObjectAtIndex(iii) as? SSTShippingInfoVos {
                originX += validString(trackingNbr.trackingNumber).sizeByWidth(font: 12).width + 10
            }
        }
        return originX
    }

    override func getItemView(_ ind: Int) -> UIView {
        if let trackingNbr = items.validObjectAtIndex(ind) as? SSTShippingInfoVos {
            let nbrLabel = UILabel(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 15))
            nbrLabel.font = UIFont.systemFont(ofSize: 12)
            nbrLabel.textColor = UIColor.hexStringToColor("#706FFC")
            nbrLabel.text = validString(trackingNbr.trackingNumber)
            
            let imgV = UIImageView(frame: CGRect(x: validString(trackingNbr.trackingNumber).sizeByWidth(font: 12).width + 5, y: nbrLabel.y + 2, width: 12, height: 12))
            imgV.image = UIImage(named: "icon_orderClicked")
            
            let outerView = UIView(frame: CGRect(x: 0, y: CGFloat(ind) * kOrderTrackingNbrCellNbrHeight, width: kScreenWidth, height: kOrderTrackingNbrCellNbrHeight))
            outerView.addSubview(nbrLabel)
            outerView.addSubview(imgV)
            return outerView
        }
        return UIView()
    }

}
