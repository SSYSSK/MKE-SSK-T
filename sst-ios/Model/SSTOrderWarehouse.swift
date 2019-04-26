//
//  SSTOrderWarehouse.swift
//  sst-ios
//
//  Created by Amy on 2017/12/25.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kShippingBaseCost        = "shippingBaseCost"
let kTaxRate                 = "taxRate"
let kShippingPrice           = "shippingPrice"
let kShippingFinalTotal      = "shippingFinalTotal"
let kNativeShippingTotal     = "nativeShippingTotal"
let kShippingCompanyName     = "shippingCompanyName"
let kOrderDiscount           = "orderDiscount"
let kOrderShippingStatusDesc = "shippingStatusDesc"
let kOrderWarehouseCompanyType = "company"
let kShippingInfoVos         = "shippingInfoVos"

class SSTOrderWarehouse: SSTWarehouse {
    
    var shippingCompanyName: String?
    var orderTax: Double?
    var taxRate: Double = 0.0
    var orderItemsTotal: Double?
    var shippingFinalTotal: Double?
    var nativeShippingTotal: Double?
    var shippingPrice: Double?
    
    var shippingBaseCost: Double?
    var shippingStatus: Double?
    var shippingStatusDesc: String?
    var orderFinalTotal: Double?
    var itemsQty: Int?
    var orderItems = [SSTOrderItem]()
    
    var shippingInfoVos = [SSTShippingInfoVos]() 
    
    var shippingCompanyId: String?  //  当前仓库会默认选择的物流公司，通过此ID判断
    var compnayType: Int?               // is Fedex or not
    var finalTax: Double? //当前仓库下的最终税（包括产品税和物流税）
    var isNeedShippingAccount: Bool {
        get {
            return validInt(self.compnayType) == 1
        }
    }
    
    var totalWithoutTax: Double {  //当前仓库下的总价，不包含税
        get {
            return validDouble(orderFinalTotal) - validDouble(shippingFinalTotal) - validDouble(shippingFinalTotal) * validDouble(taxRate)
        }
    }
    
    var taxWithoutProduct: Double { //不包含产品税的税
        get {
            return validDouble(orderTax) - validDouble(shippingFinalTotal) * validDouble(taxRate)
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.shippingFinalTotal <- map[kOrderShippingFinalTotal]
        self.shippingBaseCost   <- map[kShippingBaseCost]
        self.orderFinalTotal    <- map[kOrderFinalTotal]
        self.itemsQty           <- map[kOrderItemQty]
        self.orderTax           <- map[kOrderTax]
//        self.orderTotal         <- map[kOrderTotal]
        self.taxRate            <- map[kTaxRate]
        self.shippingPrice      <- map[kShippingPrice]
        self.nativeShippingTotal      <- map[kNativeShippingTotal]

        self.orderItemsTotal        <- map[kOrderItemsTotal]
        self.shippingCompanyId      <- (map[kOrderCompanyId],transformIntToString)
        self.orderItems             <- map[kOrderItems]
        self.shippingStatus         <- map[kOrderShippingStatus]
        self.shippingStatusDesc     <- (map[kOrderShippingStatusDesc])
        self.shippingInfoVos        <- map[kShippingInfoVos]
        self.shippingCompanyName    <- map[kShippingCompanyName]
        self.compnayType            <- map[kOrderWarehouseCompanyType]
    }
    
    func removeItem(id: String) {
        for ind in 0 ..< self.orderItems.count {
            if self.orderItems[ind].id == id {
                self.orderItems.remove(at: ind)
                break
            }
        }
    }
    
    func addItem(orderItem: SSTOrderItem) {
        var found = false
        for ind in 0 ..< self.orderItems.count {
            if self.orderItems[ind].id == orderItem.id {
                self.orderItems[ind].qty += orderItem.qty
                found = true
                break
            }
        }
        if !found {
            self.orderItems.append(orderItem)
        }
    }
    
    func getItemQty(itemId: String) -> Int {
        for itm in orderItems {
            if itm.id == itemId {
                return itm.qty
            }
        }
        return 0
    }
}
