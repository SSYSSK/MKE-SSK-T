//
//  SSTSeries.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kSeriesId            = "seriesId"
let kSeriesName          = "seriesName"
let kSeriesImageUrl      = "imageUrl"

class SSTSeries: BaseModel {
    
    var seriesId : Int!
    var seriesName: String!
    var imgUrl: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        seriesId          <- map[kSeriesId]
        seriesName        <- map[kSeriesName]
        imgUrl            <- map[kSeriesImageUrl]
    }
}
