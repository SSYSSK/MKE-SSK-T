//
//  SSTFreeShippingInfo.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kFreeShippingInfoLogo        = "freeShippingCompanyLogo"
let kFreeShippingInfoCompanyName = "freeShippingCompanyName"
let kFreeShippingInfoTip         = "freeShippingTip"

class SSTFreeShippingInfo: BaseModel {
    
    var logo: String?
    var companyName: String?
    var tip: String?

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        logo            <- map["\(kFreeShippingInfoLogo)"]
        companyName     <- map["\(kFreeShippingInfoCompanyName)"]
        tip             <- map["\(kFreeShippingInfoTip)"]
    }
}
