//
//  SSTSetting.swift
//  sst-ios
//
//  Created by Amy on 2017/1/6.
//  Copyright © 2017年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kSettingsTitle = "title"
let kSettingsUrl   = "url"
let kSettingsId    = "itemid"

class SSTSetting: BaseModel {

    var items = [SSTSetting]()
    
    var title: String?
    var url: String?
    var id: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func update(_ data: NSArray) {
        var infos  = [SSTSetting]()
        for itemInfo in validNSArray(data) {
            if let item = SSTSetting(JSON: validDictionary(itemInfo)) {
                infos.append(item)
            }
        }
        self.items = infos
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        title <- map[kSettingsTitle]
        url   <- map[kSettingsUrl]
        id    <- (map[kSettingsId],transformIntToString)
    }

    func fetchData() {
        biz.getSettingInformations { (data, error) in
            if data != nil {
                self.update(validNSArray(data))
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }
}
