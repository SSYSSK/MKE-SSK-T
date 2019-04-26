//
//  SSTOrderPayInfoCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/30.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTOrderPayInfoCell: SSTBaseCell {
    
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var originSubTotal: UILabel!
    @IBOutlet weak var discount: UILabel!
    // 收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    func setData(_ price: Double, oldPrice:Double, discount: Double){
        self.subTotal.text = price.formatC()
        if price.formatC() == oldPrice.formatC() {
            self.originSubTotal.isHidden = true
        } else {
            self.originSubTotal.isHidden = false
            self.originSubTotal.attributedText = oldPrice.formatC().strikeThrough()
        }
        if discount < kOneInMillion {
            self.discount.text = discount.formatC()
        } else {
            self.discount.text = "-" + discount.formatC()
        }
    }

}
