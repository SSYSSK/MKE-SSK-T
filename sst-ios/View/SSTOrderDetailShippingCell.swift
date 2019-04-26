 //
//  SSTOrderDetailShippingCell.swift
//  sst-ios
//
//  Created by 天星 on 2018/1/5.
//   © 2018年 ios. All rights reserved.
//

import UIKit

class SSTOrderDetailShippingCell: UITableViewCell {

    @IBOutlet weak var txNameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var shippingPriceLabel: UILabel!
    @IBOutlet weak var nativeshippingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    var  warehouses : SSTOrderWarehouse? {
        didSet{
            txNameLabel.text = warehouses?.warehouseName
            companyNameLabel.text = warehouses?.shippingCompanyName
            shippingPriceLabel.text = warehouses?.shippingPrice?.formatC()
            nativeshippingLabel.text = warehouses?.nativeShippingTotal?.formatC()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
