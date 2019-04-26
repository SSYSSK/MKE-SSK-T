//
//  SSTOrderShippingFromCell.swift
//  sst-ios
//
//  Created by Amy on 2018/1/18.
//  Copyright © 2018年 ios. All rights reserved.
//

import UIKit

class SSTOrderShippingFromCell: SSTBaseCell {

    @IBOutlet weak var warehouseName: UILabel!
    @IBOutlet weak var qty: UILabel!
    
    var info: SSTOrderWarehouse? {
        didSet {
            let itemStr = "\(validInt(info?.orderItems.count))" + (validInt(info?.orderItems.count) > 1 ? " items" : " item")
            let pcsStr = "\(validInt(info?.itemsQty)) pcs"
            let totalStr = validString(info?.orderItemsTotal?.formatC())
            self.warehouseName.text = validString(info?.warehouseName)
            self.qty.text = "(\(itemStr), \(pcsStr), \(totalStr))"
        }
    }
}
