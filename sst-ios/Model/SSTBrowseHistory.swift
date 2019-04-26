//
//  SSTRecentlyViewed.swift
//  sst-ios
//
//  Created by Amy on 2016/10/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let dataList = "list"
let totalProduct = "total"

class SSTBrowseHistory: BaseModel {
    
    var groups = [SSTGroup]()
    
    var items = [SSTHistoryItem]() {
        didSet {
            var groups = [SSTGroup]()
            for item in self.items {
                let groupName = validString(item.dateBrowsed?.formatMMddyy())
                if let group = SSTGroup.findGroup(name: groupName, within: groups) {
                    group.items.append(item)
                } else {
                    let nGroup = SSTGroup(groupName)
                    nGroup.items.append(item)
                    groups.append(nGroup)
                }
            }
            self.groups = groups
        }
    }
    
    var pageNum = 1
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func getItemIndex(_ item: SSTHistoryItem) -> Int {
        for ind in 0 ..< self.items.count {
            if item.id == self.items[ind].id {
                return ind
            }
        }
        return -1
    }
    
    func update(_ data: Array<Any>) {
        var tItms = [SSTHistoryItem]()
        for itemDict in data {
            if let nItem = SSTHistoryItem(JSON: validDictionary(itemDict)) {
                if getItemIndex(nItem) == -1 {
                    tItms.append(nItem)
                }
            }
        }
        tItms.sort { (itm1, itm2) -> Bool in
            itm1.dateBrowsed?.compare(validDate(itm2.dateBrowsed)) == .orderedDescending
        }
        self.items.append(contentsOf: tItms)
    }
    
    func fetchData(_ pageNum: Int = 1, callback: RequestCallBack? = nil) {
        biz.getBrowseHistory(pageNum, pageSize: kPageSize) { [weak self] (data, error) in
            if error == nil {
                if pageNum == 1 { //第一次，清空数组
                    self?.items.removeAll()
                }
                
                self?.pageNum = pageNum
                self?.update(validArray(data))
                self?.delegate?.refreshUI(self)
            }
            callback?(self?.items, error)
        }
    }
    
    func fetchDataForNextPage(callback: RequestCallBack? = nil) {
        let tPageNum = self.items.count / kPageSize + 1
        self.fetchData(tPageNum, callback: callback)
    }

    func removeFromBrowseHistory(_ items: [SSTItem],callback: @escaping RequestCallBack) {
        biz.removeFromBrowseHistory(items) { (data, error) in
            if error == nil {
                for item in items {
                    for ind in 0 ..< self.items.count {
                        if self.items[ind].id == item.id {
                            self.items.remove(at: ind)
                            break
                        }
                    }
                }
                callback(200,nil)
            } else {
                SSTToastView.showError("Delete item failed, please try again")
            }
        }
    }
    
    func removeAllHistory(_ callback: @escaping RequestCallBack) {
        biz.removeAllBrowseHistory { (data, error) in
            if error == nil {
                callback(data, error)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
}
