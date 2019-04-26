//
//  SSTShippingInfoVos.swift
//  sst-ios
//
//  Created by Amy on 2017/7/31.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kOrderShippingSn        = "shippingSn"
let kOrderTrackingUrl       = "trackingUrl"
let kOrderCompanyId         = "shippingCompanyId"

class SSTShippingInfoVos: BaseModel {
    
    var trackingNumber: String?
    var companyName: String?
    var orderId: String?
    var trackingUrl: String?
    var companyId: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        trackingNumber  <- map[kOrderShippingSn]
        companyName     <- map[kShippingCompanyName]
        orderId         <- (map[kOrderId],transformIntToString)
        trackingUrl     <- map[kOrderTrackingUrl]
        companyId       <- (map[kOrderCompanyId],transformIntToString)
    }
}
