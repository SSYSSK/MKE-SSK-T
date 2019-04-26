//
//  SSTWareHouseInfo.swift
//  sst-ios
//
//  Created by Amy on 2017/12/22.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kWarehouseName = "whName"
let kWarehouseId   = "whId"

class SSTWarehouse: BaseModel {

    var warehouseName: String?
    var warehouseId: Int?
    
    var shippingCompanies = [SSTShippingCostInfo]()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        warehouseId   <- map[kWarehouseId]
        warehouseName <- map[kWarehouseName]
    }
}
