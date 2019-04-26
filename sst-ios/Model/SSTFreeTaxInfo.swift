//
//  SSTFreeTaxInfo.swift
//  sst-ios
//
//  Created by Amy on 2016/12/9.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kTaxInfoStatus  = "applyStatus"
let kTaxInfoUserId  = "userId"
let kTaxInfoEndDate = "endDate"
let kTaxInGracePeriod = "inGracePeriod"

class SSTFreeTaxInfo: BaseModel {
    
    var status: String?
    var userId: String?
    var endDate: Date?
    var inGracePeriod: Int?   // 是否是宽限期内，0表示不在宽限期，1表示在宽限期
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        if map.JSON.keys.count <= 0 {
            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        inGracePeriod <- map[kTaxInGracePeriod]
        status  <- (map[kTaxInfoStatus],transformIntToString)
        userId  <- (map[kTaxInfoUserId],transformIntToString)
        endDate <- (map[kTaxInfoEndDate],transformStringToDate)
        
    }
    
}
