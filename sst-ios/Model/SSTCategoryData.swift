//
//  SSTCategoryData.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/20/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTCategoryData: BaseModel {
    
//    var levelObj: SSTLevelObject!    // for showing level
    var category: SSTCategory!
    
    override init() {
        super.init()
        
        category = SSTCategory()
//        category.name = "All Departments"
//        levelObj = SSTLevelObject(obj: category, level: 0)
//        
//        if let arr = FileOP.unarchive(kCategoryFileName) {
//            self.refreshData(validArray(arr))
//        }
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func refreshData(_ arr: Array<AnyObject>) {
        var categories = [SSTCategory]()
        for dict in arr {
            if let category = SSTCategory(JSON: validDictionary(dict)) {
                categories.append(category)
            }
        }
        
        self.category.subs = categories
//        self.levelObj.subs = getLevelObjects(categories, level: 1)
    }
    
    func getLevelObjects(_ categories: [SSTCategory]?, level: Int) -> [SSTLevelObject] {
        if let tmpCategories = categories {
            var levelObjs = [SSTLevelObject]()
            for category in tmpCategories {
                let levelObj = SSTLevelObject(obj: category, level: level)
                levelObj.subs = getLevelObjects(category.subs, level: level + 1)
                levelObjs.append(levelObj)
            }
            return levelObjs
        }
        return [SSTLevelObject]()
    }
    
    func fetchData(parentId: String? = nil) {
        biz.getCategories(parentId: parentId) { (data, error) in
            if error == nil, let tmpData = data {
                self.refreshData(validArray(data))
                FileOP.archive(kCategoryFileName, object: tmpData)
                self.delegate?.refreshUI(self)
            } else {
                if validBool(getTopVC()?.isKind(of: SSTCategoryVC.classForCoder())) {
                    SSTToastView.showError(validString(error))
                }
                self.delegate?.refreshUI(error)
            }
        }
    }

}
