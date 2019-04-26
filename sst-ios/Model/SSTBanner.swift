//
//  SSTBannerModel.swift
//  sst-ios
//
//  Created by Amy on 16/4/18.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kBannerUrl    = "bannerUrl"
let kBannerTarget = "bannerTarget"
let kBannerId     = "bannerId"
let kBannerZone   = "bannerZone"
let kBannerTitle  = "bannerTitle"
let kBannerType   = "bannerType"
let kBannerFile   = "bannerFile"

let kBannerItemType     = "bannerItemType"
let kBannerItemTitle    = "bannerTitle"
let kBannerItemValue    = "bannerItem"
let kBannerFlagIcon     = "flagIcon"

class SSTBanner: BaseModel {
    
    var bannerUrl: String?
    var bannerTarget: String?
    var bannerId: String?
    var bannerZone: Int?
    var bannerTitle: String?
    var bannerType: Int?
    var bannerFile: String?
    
    var type: String?
    var title: String?
    var value: String?
    var flagIcon: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if map.JSON[kBannerId] == nil {
            printDebug("Error. banner is nil !JSON:\(map.JSON)")
            return
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        bannerUrl    <- map[kBannerUrl]
        bannerTarget <- map[kBannerTarget]
        bannerId     <- (map[kBannerId],transformIntToString)
        bannerZone   <- map[kBannerZone]
        bannerTitle  <- map[kBannerTitle]
        bannerType   <- map[kBannerType]
        bannerFile   <- map[kBannerFile]
        
        type         <- map[kBannerItemType]
        title        <- map[kBannerItemTitle]
        value        <- map[kBannerItemValue]
        flagIcon     <- map[kBannerFlagIcon]
    }
}
