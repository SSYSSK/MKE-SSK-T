//
//  SSTState.swift
//  sst-ios
//
//  Created by Amy on 16/7/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kStateName  = "stateName"
let kStateId    = "stateId"
let kStateCode  = "stateCode"

class SSTState: BaseModel {
    
    var name: String?
    var id: String?
    var code: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        if map.JSON[kStateId] == nil {
            printDebug("Error. state is nil! \(map.JSON)")
            return
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        name <- map[kStateName]
        id   <- (map[kStateId],transformIntToString)
        code <- map[kStateCode]
    }
}
