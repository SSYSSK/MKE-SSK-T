//
//  SSTPaymentInfoCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/7.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTPaymentInfoCell: SSTBaseCell, UITextViewDelegate {

    @IBOutlet weak var regularPrice: UILabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    
    func setData(price: Double, oldPrice: Double, discount: Double) {
        self.regularPrice.text = price.formatC()
        
        if oldPrice - price > kOneInMillion {
            self.oldPrice.isHidden = false
            self.oldPrice.text = oldPrice.formatC()
        } else {
            self.oldPrice.isHidden = true
            self.oldPrice.text = ""
        }
        
        if discount > kOneInMillion {
            self.discount.text = "- \(discount.formatC())"
        } else {
            self.discount.text = 0.formatC()
        }
    }
}
