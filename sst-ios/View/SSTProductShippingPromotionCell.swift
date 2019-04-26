//
//  SSTProductShippingCell.swift
//  sst-ios
//
//  Created by Amy on 16/5/25.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTProductShippingPromotionCell: SSTBaseCell {

    @IBOutlet weak var shippingInfo: UILabel!
    var info: String = String() {
        didSet {
            let preInfo = "Free "
            shippingInfo.text = info
            let attributedStr = NSMutableAttributedString(string: validString(shippingInfo.text))
            let range = NSMakeRange(0, preInfo.count)
            attributedStr.addAttribute(NSAttributedStringKey.foregroundColor, value:( UIColor.green), range: range)
            shippingInfo.attributedText = attributedStr

        }
    }

}
