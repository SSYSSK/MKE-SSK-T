//
//  SSTCountry.swift
//  sst-ios
//
//  Created by Amy on 16/7/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kCountryCode     = "countryCode"
let kCountryPriority = "countryPriority"
let kCountryName     = "countryName"
let kCountryId       = "countryId"

class SSTCountry: BaseModel {
    
    var id: String?
    var code: String?
    var name: String?
    var priority = 0
    var states = [SSTState]()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if map.JSON[kCountryId] == nil {
            printDebug("Error. Country is nil! \(map.JSON)")
            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        code     <- map[kCountryCode]
        priority <- map[kCountryPriority]
        name     <- map[kCountryName]
        id       <- (map[kCountryId],transformIntToString)
    }
}
