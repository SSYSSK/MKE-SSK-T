//
//  SSTFeedback.swift
//  sst-ios
//
//  Created by Amy on 2016/11/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kSolutionTitle = "articletitle"
let kSolutionURL   = "url"

class SSTFeedback: BaseModel {

    var title: String!
    var url: String!

    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        title <- map[kSolutionTitle]
        url <- map[kSolutionURL]
    }

}
