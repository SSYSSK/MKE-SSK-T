//
//  SSTPaymentType.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/9.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let KPaymentId      = "paymentid"
let kPaymentname    = "paymentname"
let kPaymentlogo    = "paymentlogo"
let kPayMessage     = "message"
let kPayIsEnable    = "enabled"
let kCodType        = "codType"
let kPaymentTypeTip = "paymentdescription"

enum SSTOrderPaymentType: Int {
    case bank = 1
    case paypal = 2
    case COD = 5
    case localPickup = 6
    case wallet = 7
    case locakPickupByCase = 8
    case shipFirst = 9
    case westernUnion = 19
    case requestDiscount = 99
}

class SSTPaymentType: BaseModel {
    
    var paymentId: String!
    var paymentname: String?
    var paymentlogo : String = ""
    var message: String?
    var isEnable = false
    var CODType = 0 /*只有COD模式下才需要用到这个变量，当COD isDispaly为0,即COD不可用的时候需要判断不可用的情况
                    0 表示用户没有申请COD，则显示applyCOD button，
                    1表示用户欠费*/
//    var isSelected = false //当前支付方式是否是选择状态
    var orderPaymentTotal = 0.0 //支付方式后面对应的价钱 = 订单总价 - 钱包支付的钱
    var orderTotal = 0.0  //当前支付方式下订单的总额（钱包已付的钱 + 未支付的钱）
    var tip: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        paymentId      <- (map[KPaymentId],transformIntToString)
        paymentname    <- map[kPaymentname]
        paymentlogo    <- map[kPaymentlogo]
        message        <- map[kPayMessage]
        isEnable       <- map[kPayIsEnable]
        CODType        <- map[kCodType]
        tip            <- map[kPaymentTypeTip]
    }

}
