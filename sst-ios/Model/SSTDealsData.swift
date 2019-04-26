//
//  SSTDeals.swift
//  sst-ios
//
//  Created by Amy on 16/8/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTDealsData: BaseModel {
    
    fileprivate(set) var groups = [SSTGroup]()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func update(dictionary dict: NSDictionary) {
        var groups = [SSTGroup]()
        for key in dict.allKeys {
            var items = [SSTItem]()
            for item in validArray(dict[validString(key)]) {
                if let kItem = SSTItem(JSON: validDictionary(item)) {
                    if validDouble(kItem.listPrice) > validDouble(kItem.promoItemPrice) {
                        items.append(kItem)
                    }
                }
            }
            let group = SSTGroup(name: validString(key), itms: items)
            groups.append(group)
        }
        self.groups = groups
    }

    func fetchData() {
        biz.getDeals { (data, error) in
            if error == nil {
                self.update(dictionary: validNSDictionary(data))
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }
    
    static func getDailyShipppingTip(callback: @escaping RequestCallBack) {
        biz.getDailyShippingTips { (data, error) in
            if error == nil, let tip = validDictionary(data)["tip"] as? String {
                callback(tip, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
}
