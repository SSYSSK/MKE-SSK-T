//
//  SSTHotProduct.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kProductId  = "productId"
let kImagesPath  = "imagesPath"

class SSTHotProduct: BaseModel {
    
    var productId: String?
    var imagesPath: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        productId      <- (map[kProductId],transformIntToString)
        imagesPath     <- map[kImagesPath]
    }
 
}
