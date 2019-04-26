//
//  SSTShippingInfoCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kCutOffTimeViewWidth = kScreenWidth - 55 - 20

enum LastOrderType: Int {
    case addToLastOrder = 17
    case addToLastOrderHasInvalid = 18
}

class SSTShippingInfoCell: SSTBaseCell {
    
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var shippingName: UILabel!
    @IBOutlet weak var shippingDetail: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var lastOrderShippingMethod: UILabel!
    @IBOutlet weak var cutOffView: UIView!
    @IBOutlet weak var cutOffInfo: UILabel!
    
    @IBOutlet weak var lastOrderMethodHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cutOffViewBottomHeightConstrain: NSLayoutConstraint!
    @IBOutlet weak var cutOffViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var cutOffImgV: UIImageView!
    @IBOutlet weak var cutOffCountdownLabel: UILabel!
    
    var lastOrderId: String?
    var lastShippingStr: String?
    
    var info: SSTShippingCostInfo! {
        didSet {
            if info.companyId == validString(LastOrderType.addToLastOrder.rawValue) || info.companyId == validString(LastOrderType.addToLastOrderHasInvalid.rawValue) {
                lastOrderShippingMethod.isHidden = false
                shippingDetail.text = "Last order number: \(validString(lastOrderId)) "
                lastOrderShippingMethod.text = "Shipping Company: \(validString(lastShippingStr))"
                let shippingHeight = lastOrderShippingMethod.text?.sizeByWidth(font: 12, width: kScreenWidth - 75).height
                lastOrderMethodHightConstraint.constant = shippingHeight!
                shippingName.textColor = kPurpleColor
            } else {
                lastOrderShippingMethod.isHidden = true
                lastOrderMethodHightConstraint.constant = 0
                shippingName.textColor = UIColor.darkGray
                shippingDetail.attributedText = validString(info.description).toAttributedString().addFontSize(size: 12).addColor(color: UIColor.gray)
            }
            
            shippingName.text =  validString(info.name)
            let tmpAmount = info.costPrice
            amount.text = tmpAmount.formatC()
            
            if info.isSelect {
                selectedIcon.image = UIImage(named: kSelectedImageName)
                if info.cutOffTime?.isNotEmpty != nil {
//                    cutOffViewHeightConstraint.constant = CGFloat(validDouble(info.cutOffTime?.heightByWidthAndNewLine(font: 12, width: kCutOffTimeViewWidth)))
//                    cutOffViewBottomHeightConstrain.constant = 5
                    cutOffInfo.attributedText = info.cutOffTime?.toAttributedString(font: UIFont.systemFont(ofSize: 12))
                    cutOffView.layer.borderColor = kPurpleColor.cgColor
                    self.refreshCountdownView()
                } else {
                    cutOffView.removeFromSuperview()
                }
            } else {
                selectedIcon.image = UIImage(named: kUnselectedImageName)
                cutOffView.removeFromSuperview()
            }
        }
    }
    
    func refreshCountdownView() {
        if validInt64(info.cutOffTimeCountDown) > 0 {
            cutOffImgV?.isHidden = false
            cutOffCountdownLabel?.text = validInt64(info.cutOffTimeCountDown).toCountdownText()
            cutOffCountdownLabel?.textColor = RGBA(36, g: 153, b: 146, a: 1)
        } else {
            cutOffImgV?.isHidden = true
            cutOffCountdownLabel?.text = info.cutOffTimeExpiredTip
            cutOffCountdownLabel?.textColor = UIColor.red.withAlphaComponent(0.9)
        }
    }
}
