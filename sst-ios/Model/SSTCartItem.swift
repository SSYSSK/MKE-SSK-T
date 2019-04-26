//
//  SSTCartItem.swift
//  sst-ios
//
//  Created by Amy on 16/5/18.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kCartOriginUnitPrice  = "outPrice"
let kCartItemQty          = "qty"
let kCartQtyPrice         = "qtyPrice"
let kCartUnitPrice        = "finalUnitPrice"
let kCartItemWeight       = "productWeight"
let kCartItemId           = "itemId"
let kCartSumOriginalPrice = "sumOriginalPrice"
let kCartSumFinalPrice    = "sumFinalPrice"
let kListPrice            = "listPrice"
let kPromoQty             = "promoQty"
let kCartBoughtPromoQty   = "boughtPromoQty"

class SSTCartItem: SSTItem {
    
    var itemId = ""
    var qty = 0                  //产品个数
    var sumOriginalPrice = 0.0   //单件商品总价（商品原始单价＊数量）
    var sumFinalPrice = 0.0      //单件商品最后总价（商品优惠单价＊数量）
    var checked = true
    var addingQty = 0            // store the sum of qty need to add in cart before sending request to server
    
    var isAdding = true
    var promoQty = 0             // 用户可以购买的打折商品数量
    
    var boughtPromoQty = 0       // have bought promo quantity of current user
    
    override init() {
        super.init()
    }
    
    init(id: String, qty: Int) {
        super.init()
        
        self.id = id
        self.qty = qty
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        itemId           <- (map[kCartItemId],transformIntToString)
        qty              <- map[kCartItemQty]
        sumOriginalPrice <- map[kCartSumOriginalPrice]
        sumFinalPrice    <- map[kCartSumFinalPrice]
        outPrice         <- map["orderItemsTotal"]
        promoQty         <- map[kPromoQty]
        boughtPromoQty   <- map[kCartBoughtPromoQty]
        
        if outPrice == nil {
            outPrice = 0
        }
    }
    
    var cartPriceDiscountPercentText: String {
        get {
            var rString = ""
            if isPromoItem {
                if validDouble(sumOriginalPrice) > validDouble(sumFinalPrice) && validDouble(sumOriginalPrice) > 0 {
                    rString = ( ( 1 - validDouble(sumFinalPrice) / sumOriginalPrice ) * 100).formatCWithoutCurrency(f: ".0")
                }
            }
            return rString.sub(start: 0, end: 1)
        }
    }
    
    var promoCountContained: Int {
        get {
            if validInt(self.promoQty) > 0 {
                if qty < validInt(self.promoQty) {
                    return qty
                } else {
                    return validInt(self.promoQty)
                }
            }
            return 0
        }
    }
    
}
