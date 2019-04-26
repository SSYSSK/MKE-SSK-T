//
//  SSTShippingCostInfo.swift
//  sst-ios
//
//  Created by Amy on 2017/1/14.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kShippingCostCompanyDescription = "shippingCompanyDescription"
let kShippingCostCompanyLogo        = "shippingCompanyLogo"
let kShippingCostCompanyName        = "shippingCompanyName"
let kShippingCostCompanyId          = "shippingCostCompanyId"
let kShippingCostId                 = "shippingCostId"
let kShippingCostPrice              = "shippingCostPrice"
let kCutOffTimeInfo                 = "cutOffTimeMsg"
let kShippingCostMetaName           = "shippingCompanyMetaName"
let kCutOffTimeExpiredTip           = "cutOffTimeExpiredTips"
let kCutOffTimeCountDown            = "cutOffTimeCountDown"

class SSTShippingCostInfo: BaseModel {
    
    var description: String?
    var logo: String?
    var costId: String?
    var companyId: String?
    var name: String?
    var costPrice: Double = 0.0
    var cutOffTime: String?
    var metaName: String?
    var shippingCompanyId: String?
    var cutOffTimeExpiredTip: String?
    var cutOffTimeCountDown: Int64?
    
    var isSelect = false

    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        if map.JSON[kShippingCostId] == nil {
            printDebug("Error. shipping cost id is nil !JSON:\(map.JSON)")
            return nil
        }
    }
    
    override func mapping(map: Map) {
        description <- map[kShippingCostCompanyDescription]
        logo        <- map[kShippingCostCompanyLogo]
        costId      <- (map[kShippingCostId],transformIntToString)
        companyId   <- (map[kShippingCostCompanyId],transformIntToString)
        name        <- map[kShippingCostCompanyName]
        costPrice   <- map[kShippingCostPrice]
        cutOffTime  <- map[kCutOffTimeInfo]
        metaName    <- map[kShippingCostMetaName]
        shippingCompanyId       <- (map[kOrderCompanyId],transformIntToString)
        cutOffTimeExpiredTip    <- map[kCutOffTimeExpiredTip]
        cutOffTimeCountDown     <- (map[kCutOffTimeCountDown], transformNSNumberToInt64)
    }

}
