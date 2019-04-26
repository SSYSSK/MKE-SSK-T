//
//  SSTProductDiscountCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/12.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTProductDiscountCell: UITableViewCell {

    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var allPriceLabel: UILabel!
    @IBOutlet weak var yourSavePriceLabel: UILabel!
    
    var productDiscount : SSTProductDiscount! {
        didSet{
            priceLabel.text = productDiscount.price?.formatC()
            countLabel.text = " * \(validString(productDiscount.minimumQty)) "
            let total: Double = validDouble(productDiscount.price) * validDouble(productDiscount.minimumQty)
            allPriceLabel.text = "= " + validString(total.formatC())
            yourSavePriceLabel.text = "Save " + validString(productDiscount.yourSave?.formatC())
        }
    }
}
