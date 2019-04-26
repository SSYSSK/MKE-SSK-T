//
//  SSTWarehouseOrderItemCellHeadView.swift
//  sst-ios
//
//  Created by 天星 on 2018/1/3.
//  Copyright © 2018年 ios. All rights reserved.
//

import UIKit

class SSTWarehouseOrderItemCellHeadView: UIView {

    @IBOutlet weak var shippingFromLabel: UILabel!
    @IBOutlet weak var shippingPriceLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
 
    var orderWarehouse: SSTOrderWarehouse? {
        didSet {
            shippingFromLabel.text = orderWarehouse?.warehouseName
            shippingPriceLabel.text = "(\(validString(orderWarehouse?.orderItems.count)) items, \(validString(orderWarehouse?.itemsQty)) pcs , \(validString(orderWarehouse?.totalWithoutTax.formatC())))"
            orderStatusLabel.text = orderWarehouse?.shippingStatusDesc
            
            if let infovos =  orderWarehouse?.shippingInfoVos {
                for i in 0..<infovos.count{
                    let label = UILabel(frame: CGRect(x: 138, y: 99 + i * 38, width: 217, height: 38))
                    label.text = infovos[i].trackingNumber
                    label.font = UIFont.systemFont(ofSize: 12)
                    label.textColor = RGBA(148, g: 151, b: 246, a: 1)
                    self.addSubview(label)
                }
            }
//            for i in 0 ..< 4 {
//                let label = UILabel(frame: CGRect(x: 138, y: 99 + i * 38, width: 217, height: 38))
//                label.text = "123"
//                label.font = UIFont.systemFont(ofSize: 12)
//                label.textColor = RGBA(148, g: 151, b: 246, a: 1)
//                self.addSubview(label)
//            }
        }
    }
}
