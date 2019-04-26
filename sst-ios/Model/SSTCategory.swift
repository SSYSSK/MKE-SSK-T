//
//  SSTCategory.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/20/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kCategoryId             = "menuId"
let kCategoryGroupId        = "menuItem"
let kCategoryName           = "menuTitle"
let kCategoryImgUrl         = "menuIcon"
let kCategorySubs           = "subMenus"
let kCategoryHaveSubMenus   = "haveSubMenus"

class SSTCategory: BaseModel {
    
    var id: String!
    var groupId: String!
    var name: String!
    
    var imgUrl: String?
    var subs: [SSTCategory]?
    var haveSubMenus: Int?
    
    var isLeaf: Bool {
        get {
            return validInt(haveSubMenus) == 0
        }
    }
    
    override init() {
        super.init()
    }
    
    init(groupId: String) {
        super.init()
        self.groupId = groupId
    }
    
    init(groupId: String, name: String) {
        super.init()
        self.groupId = groupId
        self.name = name
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if validString(map.JSON[kCategoryId]) == "" {
            printDebug("Error. Category is nil !JSON:\(map.JSON)")
            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id              <- (map[kCategoryId], transformIntToString)
        groupId         <- map[kCategoryGroupId]
        name            <- map[kCategoryName]
        imgUrl          <- map[kCategoryImgUrl]
        subs            <- map[kCategorySubs]
        haveSubMenus    <- map[kCategoryHaveSubMenus]
    }
    
    static func getLeafIdsForSearch(_ category: SSTCategory) -> [String] {
        if validInt(category.subs?.count) <= 0 {
            return [category.groupId]
        } else {
            var ids = [String]()
            for ind in 0 ..< validInt(category.subs?.count) {
                if let subs = category.subs {
                    let subLeafIds = getLeafIdsForSearch(subs[ind])
                    ids.append(contentsOf: subLeafIds)
                }
            }
            return ids
        }
    }
    
}
