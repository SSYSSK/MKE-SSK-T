//
//  SSTShoppingCart.swift
//  sst-ios
//
//  Created by Amy on 16/5/6.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kOrderItemId     = "orderItemsId"
let kOrderItemStatus = "orderItemStatus"
let kOrderItemName   = "orderProductName"
let kOrderItemPrice  = "orderCalcProductPrice"
let kOrderItemQty    = "orderProductQty"
let kOrderItemWeight = "orderProductWeight"
let kOrderItemThumbnail = "orderProductThumbnailPath"
let kOrderItemProductId = "orderProductId"
//let kOrderPromePrice    = "promoPrice"

// Search keyword
let kSearchOrderItemId        = "ORDERPRODUCTID"
let kSearchOrderItemName      = "ORDERPRODUCTNAME"
let kSearchOrderItemStatus    = "ORDERITEMSTATUS"
let kSearchOrderItemPrice     = "ORDERPRODUCTPRICE"
let kSearchOrderItemQty       = "ORDERPRODUCTQTY"

let kOrderItemWarehouseId           = "whId"
let kOrderItemShippingCompanyId     = "shippingCompanyId"

let kWarehouseOrderItemId   = "orderProductId"
let kOrderProductPrice      = "orderProductPrice"

class SSTOrderItem: SSTItem {
    
    var qty = 0
    
    var warehouseId: String?
    var shippingCompanyId: String?
    var sumFinalPrice = 0.0
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        status      <- map[kSearchOrderItemStatus]
        qty         <- map[kSearchOrderItemQty]
        name        <- map[kOrderItemName]
        id          <- map[kOrderItemId]
        
        if id.isEmpty {
            id          <- (map[kWarehouseOrderItemId], transformIntToString)
        }
        
        thumbnail   <- map[kOrderItemThumbnail]
        
        if map.JSON[kOrderId] != nil {
            qty <- map[kOrderItemQty]
        }
        
        outPrice    <- map[kOrderItemPrice]
        
        warehouseId         <- map[kOrderItemWarehouseId]
        shippingCompanyId   <- map[kOrderItemShippingCompanyId]
        sumFinalPrice       <- map[kCartSumFinalPrice]
        
        if map.JSON.keys.contains(kOrderProductPrice) {     // for warehouse item
            outPrice    <- map[kOrderProductPrice]
        }
    }
}

