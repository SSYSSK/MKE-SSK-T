//
//  LevelObject.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/22/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTLevelObject {
    
    var obj: AnyObject!
    var level: Int!
    var isExpanded: Bool!
    var subs: [SSTLevelObject]?
    
    init(obj: AnyObject, level: Int = 0) {
        self.obj = obj
        self.level = level
        self.isExpanded = false
    }

}
