//
//  SSTShippingCompany.swift
//  sst-ios
//
//  Created by Amy on 16/6/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kFreethreshold        = "shippingCompanyFreeThreshold"
let kCompanyType          = "shippingCompanyInt"
//let kShippingCompanyName  = "shippingCompanyName"
let kDescription          = "shippingCompanyDescription"
let kPriority             = "shippingCompanyPriority"
let kFreeDays             = "shippingCompanyFreeDays"
let kShippingCompanyId    = "shippingCostCompanyId"
let kCod                  = "shippingCompanyCod"
let kLogo                 = "shippingCompanyLogo"

class SSTShippingCompany: BaseModel {
    
    var freeThreshold: Double?  //最低费用
    var type: Int?              //国际快递 0-非国际 1-国际
    var name: String!
    var notes: String?
    var priority: Int?          //级别
    var freeDays: String?       //休息日
    var id: String?
    var cod: Int?               //货到付款 0-不支持 1-支持
    var isSelect = false
    var logo: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        freeThreshold <- map[kFreethreshold]
        type          <- map[kCompanyType]
        name          <- map[kShippingCompanyName]
        notes         <- map[kDescription]
        priority      <- map[kPriority]
        freeDays      <- map[kFreeDays]
        id            <- (map[kShippingCompanyId],transformIntToString)
        cod           <- map[kCod]
        logo          <- map[kLogo]
    }
}

