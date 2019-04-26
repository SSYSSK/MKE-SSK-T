//
//  SSTProductShippingInfoCell.swift
//  sst-ios
//
//  Created by Amy on 16/5/25.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTProductShippingInfoCell: SSTBaseCell {

    @IBOutlet weak var skuNumber: UILabel!
    @IBOutlet weak var shippingInfo: UILabel!
    
    var sku: String = String () {
        didSet {
            skuNumber.text = "SKU: " + sku
        }
    }
    
    var info: String = String() {
        didSet {
            let preInfo = "Shipping Info: "
            shippingInfo.text = preInfo + info
            let attributedStr = NSMutableAttributedString(string: validString(shippingInfo.text))
            let range = NSMakeRange(0, preInfo.count)
            attributedStr.addAttribute(NSAttributedStringKey.foregroundColor, value:( UIColor.lightGray), range: range)
            shippingInfo.attributedText = attributedStr
        }
    }
    
}
