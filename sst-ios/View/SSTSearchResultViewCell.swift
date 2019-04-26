//
//  SSTSearchResultViewCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/23.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTSearchResultViewCell: UITableViewCell {

    @IBOutlet weak var priceInfoLabel: UILabel!
    @IBOutlet weak var saveInfoLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var iconLeadingConstraint: NSLayoutConstraint!

    var productDiscount  = SSTProductDiscount() {
        didSet {

            priceInfoLabel.text = "\(validDouble(productDiscount.price).formatC()) * \(validInt(productDiscount.minimumQty)) = \((validDouble(productDiscount.minimumQty)*validDouble(productDiscount.price)).formatC())"
            saveInfoLabel.text = "Save \(validDouble(productDiscount.yourSave).formatC())"
        }
    }
    
    var layoutStyle : SearchResultLayoutStyle = .grid {
        didSet {
            if layoutStyle == SearchResultLayoutStyle.grid {

                UIView.animate(withDuration: 0.3, animations: {
                    if kIsIphone5 {
                        self.iconLeadingConstraint.constant = 10
                    } else {
                        self.iconLeadingConstraint.constant = kScreenWidth * 0.065
                    }
//                    self.iconX.constant = 20 * kProkScreenWidth

                    self.icon.layoutIfNeeded()
                    self.saveInfoLabel.layoutIfNeeded()
                    self.priceInfoLabel.layoutIfNeeded()

                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.iconLeadingConstraint.constant = 1
                    self.icon.layoutIfNeeded()
                    self.saveInfoLabel.layoutIfNeeded()
                    self.priceInfoLabel.layoutIfNeeded()
                })
            }
        }
    }
}
