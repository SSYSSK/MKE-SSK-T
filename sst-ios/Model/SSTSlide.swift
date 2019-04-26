//
//  SSTSlides.swift
//  sst-ios
//
//  Created by Amy on 16/4/20.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kSlideSort     = "isSort"
let kSlideItem     = "isItem"
let kSlideId       = "isId"
let kSlideType     = "isType"
let kSlideValue    = "value"
let kSlideImg      = "isImg"
let kSlidePosition = "isPosition"
let kSlideTitle    = "isTitle"

class SSTSlide: BaseModel, URLStringConvertible {
    
    var sort: Int?
    var item: String?
    var id: String?
    var type: String?
    var value: String?
    var img: String?
    var position: Int?
    var title: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if validString(map.JSON[kSlideId]) == "" {
            printDebug("error, slide is nil \(map.JSON)")
            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        sort     <- map[kSlideSort]
        item     <- map[kSlideItem]
        id       <- (map[kSlideId],transformIntToString)
        type     <- map[kSlideType]
        value    <- map[kSlideItem]
        img      <- map[kSlideImg]
        position <- map[kSlidePosition]
        title    <- map[kSlideTitle]
    }
    
    var URLString: String {
        get {
            return validString(self.img)
        }
    }
    
}
