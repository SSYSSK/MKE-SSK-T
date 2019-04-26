//
//  SSTWarehouseShippingView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/12/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

let kWarehouseShippingViewHeight: CGFloat = 47

class SSTWarehouseShippingView: UIView {

    @IBOutlet weak var warehouseNameLabel: UILabel!
    @IBOutlet weak var shippingFeeLabel: UILabel!
    @IBOutlet weak var originShippingFeeLabel: StrickoutLabel!
    @IBOutlet weak var shippingCompanyNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setInfo(warehouseName: String, shippingFee: Double,originShippingFee: Double, shippingCompanyName: String) {
        warehouseNameLabel.text = warehouseName
        shippingFeeLabel.text = shippingFee.formatC()
        let originShippingFeeStr = originShippingFee - shippingFee > kOneInMillion ? originShippingFee.formatC() : ""
        originShippingFeeLabel.text = originShippingFeeStr
        shippingCompanyNameLabel.text = shippingCompanyName
    }
    
}
