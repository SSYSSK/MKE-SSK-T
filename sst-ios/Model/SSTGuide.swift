//
//  SSTGuide.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/8/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kGuideId        = "id"
let kGuideImagePath = "imagepath"
let kGuideTitle     = "title"
let kGuideContent   = "content"

class SSTGuide: BaseModel, URLStringConvertible {
    
    var id: Int!
    var imgUrl: String!
    var title: String!
    var content: String!
    var number:Int = 0
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if map.JSON[kGuideImagePath] == nil {
            printDebug("Error. image path is nil! \(map.JSON)")
            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id      <- map[kGuideId]
        imgUrl  <- map[kGuideImagePath]
        title   <- map[kGuideTitle]
        content <- map[kGuideContent]
    }
    
    var URLString: String {
        get {
            return imgUrl
        }
    }

}
