//
//  SSTDiscountCategoryVo.swift
//  sst-ios
//
//  Created by 天星 on 17/3/20.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let KDiscountCategoryId             = "groupId"
let kDiscountCategoryTitle          = "categoryTitle"
let kDiscountValue                  = "discountValue"
let kDiscountTip                    = "discountCategoryTip"

class SSTCategoryDiscount: BaseModel {
   
    var id: Int?
    var title: String?
    var value: Int?
    var tip: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id             <- map[KDiscountCategoryId]
        title          <- map[kDiscountCategoryTitle]
        value          <- map[kDiscountValue]
        tip            <- map[kDiscountTip]
    }

}
