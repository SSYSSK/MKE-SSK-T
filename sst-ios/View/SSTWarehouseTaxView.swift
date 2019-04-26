//
//  SSTWarehouseTaxView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/12/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

class SSTWarehouseTaxView: UIView {

    @IBOutlet weak var warehouseNameLabel: UILabel!
    @IBOutlet weak var taxFeeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setInfo(warehouseName: String, taxFee: Double) {
        warehouseNameLabel.text = warehouseName
        taxFeeLabel.text = taxFee.formatC()
    }
    
}
