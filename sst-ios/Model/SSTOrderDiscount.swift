//
//  SSTDiscountOrderVo.swift
//  sst-ios
//
//  Created by 天星 on 17/3/20.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let KDiscountOrderId             = "discountOrderId"
let kOrderDiscountValue          = "discountOrderDiscountValue"
let kOrderMinCartValue           = "discountOrderMinCartValue"

class SSTOrderDiscount: BaseModel {
    
    var orderId : Int! = 0
    var value: Int! = 0
    var minCartValue: Double! = 0
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        orderId                 <- map[KDiscountOrderId]
        value                   <- map[kOrderDiscountValue]
        minCartValue            <- map[kOrderMinCartValue]
    }
}

//"<p>Get extra <span style=\"color: #ff9900;\"><strong>(discountOrderDiscountValue % ) off</strong></span> - over $discountOrderMinCartValue </p>",
