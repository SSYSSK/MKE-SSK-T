//
//  SSTOrderDetailFeeCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/22.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTOrderDetailFeeCell: SSTBaseCell {

    @IBOutlet weak var realPayment: UILabel!
    @IBOutlet weak var originPrice: StrickoutLabel!
    
    func setData(_ currentPrice: Double, originPrice: Double) {
        self.realPayment.text = currentPrice.formatC()
        
        if originPrice - currentPrice > kOneInMillion {
            self.originPrice.text = originPrice.formatC()
        } else {
            self.originPrice.text = ""
        }
    }
}
