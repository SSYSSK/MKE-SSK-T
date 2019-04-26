//
//  SSTWareHouseInfo.swift
//  sst-ios
//
//  Created by Amy on 2017/12/22.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kWarehouseName      = "whName"
let kWarehouseId        = "whId"
let kWarehouseInventory = "whInventory"

class SSTWarehouse: BaseModel {

    var warehouseName: String?
    var warehouseId: String?
    var productInventory: Dictionary<String, Int> = Dictionary<String, Int>()
    var shippingCostInfos: [SSTShippingCostInfo]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        warehouseId         <- (map[kWarehouseId], transformIntToString)
        warehouseName       <- map[kWarehouseName]
    }
    
    static func findWarehouse(id: String, warehouses: [SSTWarehouse]) -> SSTWarehouse? {
        for wh in warehouses {
            if id == validString(wh.warehouseId) {
                return wh
            }
        }
        return nil
    }
    
    func isItemInStock(itemId: String, itemQty: Int) -> Bool {
        if validInt(productInventory[itemId]) >= itemQty {
            return true
        }
        return false
    }
}
