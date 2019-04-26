//
//  Group.swift
//  sst-ios
//
//  Created by Amy on 16/8/9.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTGroup {
    
    var name: String!
    var items: [AnyObject]!
    
    init(_ name: String) {
        self.name = name
        self.items = [AnyObject]()
    }
    
    init(name: String, itms: [AnyObject]) {
        self.name = name
        self.items = itms
    }
    
    static func findGroup(name: String, within groups: [SSTGroup]) -> SSTGroup? {
        for group in groups {
            if group.name == name {
                return group
            }
        }
        return nil
    }
    
}
