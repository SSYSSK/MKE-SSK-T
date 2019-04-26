//
//  SSTProductDiscount.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/23.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kItemProductDiscountMinimumQty    = "minimumQty"
let kItemProductDiscountPrice         = "price"
let kItemProductDiscountYourSave      = "yourSave"

class SSTProductDiscount: BaseModel {
    
    var minimumQty: Int?
    var price: Double?
    var yourSave: Double?
 
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        minimumQty    <- map[kItemProductDiscountMinimumQty]
        price         <- map[kItemProductDiscountPrice]
        yourSave      <- map[kItemProductDiscountYourSave]
    }

}
