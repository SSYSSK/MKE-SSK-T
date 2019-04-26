//
//  GlobalConfigs.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/21/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kGlobalConfigsFreeTaxSwitch = "FREE_TAX_SWITCH"

class GlobalConfigs: BaseModel {
    
    var freeTaxSwitch: String?
    
    override init() {
        super.init()
        
        if let data = FileOP.unarchive(kGlobalConfigsFileName) as? Dictionary<String, Any> {
            self.update(dict: data)
        }
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        freeTaxSwitch    <- map[kGlobalConfigsFreeTaxSwitch]
    }
    
    func update(dict: Dictionary<String,Any>) {
        mapping(map: Map(mappingType: .fromJSON, JSON: dict))
    }
    
    func fetchData() {
        biz.getGlobalConfigs() { (data, error) in
            if error == nil && data != nil {
                self.update(dict: validDictionary(data))
                FileOP.archive(kGlobalConfigsFileName, object: validDictionary(data))
            }
        }
    }
}
