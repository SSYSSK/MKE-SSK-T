//
//  SSTBrand.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kBrandId             = "brandId"
let kBrandName          = "brandName"
let kBrandLogo         = "brandLogo"
let kBrandDevices         = "devices"

class SSTBrand: BaseModel {
    
    var brandId : Int!
    var brandName: String!
    var brandLogo: String?
    var devices: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        brandId          <- map[kBrandId]
        brandName        <- map[kBrandName]
        brandLogo        <- map[kBrandLogo]
        devices          <- map[kBrandDevices]
    }
}
