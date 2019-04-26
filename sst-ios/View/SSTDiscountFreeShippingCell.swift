//
//  SSTDiscountFreeShippingCell.swift
//  sst-ios
//
//  Created by Amy on 2016/11/3.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTDiscountFreeShippingCell: SSTBaseCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    var info: SSTFreeShippingInfo! {
        didSet {
            content.text = info.tip
            title.text = info.companyName
        }
    }
}
