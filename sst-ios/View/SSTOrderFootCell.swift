//
//  SSTOrderFootCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/20.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTOrderFootCell: SSTBaseCell {

    @IBOutlet weak var orderCounts: UILabel!
    @IBOutlet weak var statusBtn: UIButton!
    
    var orderClicked: ((_ order: SSTOrder) -> Void)?
    
    var order: SSTOrder! {
        didSet {
//            if case 70 ..< 80 = order.status {
//                statusBtn.setTitle("To pay", for: .normal)
//            } else if case 80 ..< 90 = order.status {
//                statusBtn.setTitle("View Logistics", for: .normal)
//            } else if case 90 ..< 100 = order.status {
//                statusBtn.setTitle("Buy again", for: .normal)
//            }
//            statusBtn.setTitle("Reorder", for: .normal)
//            orderCounts.text = "Items: \(order.items.count), Total: \(order.total.formats())"
        }
    }
    
    @IBAction func clickOrderStatusEvent(sender: AnyObject) {
        var qtys = [Int]()
        for item in order.items {
            qtys.append(item.qty)
        }
        biz.cart.addItems(order.items, addingQtys: qtys)
        orderClicked?(order)
    }

}
