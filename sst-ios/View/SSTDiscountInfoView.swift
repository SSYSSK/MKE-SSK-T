//
//  SSTDiscountInfoView.swift
//  sst-ios
//
//  Created by Amy on 16/8/9.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTDiscountInfoView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var discountInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
   
    func setDiscount(_ discount: Double, money: Double) {
        self.discountInfo.text = "Get extra " + discount.formatC() + "% off on orders over USD " + money.formatC()
    }
}
