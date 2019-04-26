//
//  SSTPaymentMethodOrderPrice.swift
//  sst-ios
//
//  Created by Amy on 2017/3/24.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kPaymentShippingTotal = "shippingFinalTotal"
let kPaymentOrderPayment  = "orderPayment"
let kPaymentAddCost       = "paymentAddCost"
let kPaymentBaseCost      = "shippingBaseCost"
let kPaymentTaxTotal      = "taxTotal"
let kPaymentFinalTotal    = "orderFinalTotal"

class SSTPaymentMethodOrderPrice: BaseModel {
    
    var shippingTotal = 0.0
    var paymentId = ""
    var paymentAddCost = 0.0
    var baseCost = 0.0
    var taxTotal = 0.0
    var orderFinalTotal = 0.0   //订单使用当前支付方式的时候，所产生的总费用
    
    var originShippingFee: Double {
        get {
            return paymentAddCost + baseCost
        }
    }
    
    var shippingFeeDiscount: Double {
        get {
            return originShippingFee - shippingTotal
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        shippingTotal   <- map[kPaymentShippingTotal]
        paymentId       <- (map[kPaymentOrderPayment],transformIntToString)
        paymentAddCost  <- map[kPaymentAddCost]
        baseCost        <- map[kPaymentBaseCost]
        taxTotal        <- map[kPaymentTaxTotal]
        orderFinalTotal <- map[kPaymentFinalTotal]
    }
    
}
