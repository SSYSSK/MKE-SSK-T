//
//  SSTHistoryItem.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/14/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kHistoryItemBrowseDate = "browseTime"

class SSTHistoryItem: SSTItem {

    var dateBrowsed: Date?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        dateBrowsed         <- (map[kHistoryItemBrowseDate], transformStringToDate)
    }
}
