//
//  SSTWarehouseHeadInfoCell.swift
//  sst-ios
//
//  Created by Amy on 2017/12/26.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTWarehouseHeadInfoCell: SSTBaseCell {

    @IBOutlet weak var whName: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var items: UILabel!
    @IBOutlet weak var qty: UILabel!
    
    @IBOutlet weak var goInImageV: UIImageView!
    
    var info: SSTOrderWarehouse? {
        didSet {
            self.whName.text = validString(info?.warehouseName)
            self.tax.text = "(Tax: \(validDouble(info?.finalTax).formatC()))"
            self.items.text = "\(validInt(info?.orderItems.count))" + (validInt(info?.orderItems.count) > 1 ? " items" : " item")
            self.qty.text = "\(validInt(info?.itemsQty)) pcs"
        }
    }
    
}
