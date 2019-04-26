//
//  SSTItemImage.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/10/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kItemImageId    = "imagesId"
let kItemImagePath  = "imagesPath"

class SSTItemImage: BaseModel {
    
    var id: String!
    var path: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id          <- map["\(kItemImageId)"]
        path        <- map["\(kItemImagePath)"]
    }

}
