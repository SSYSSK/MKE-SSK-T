//
//  SSTItemData.swift
//  sst-ios
//
//  Created by Amy on 16/7/1.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kNewArrivalsData           = "data"

struct Facet {
    var key: String
    var value: Int
    var type: String
    var isExpanded: Bool
}

class SSTItemData: SSTSearchData {
    
    var items = [SSTItem]()
    var historyKeywords: [String]!
    
    var groups: [SSTGroup]?
    
    var categoryFacets = [Facet]()
    var colorsFacets = [Facet]()
    var carriersFacets = [Facet]()
    
    // for search next page without other parameters when ItemDetailsVC
    fileprivate var prevKey: String?
    fileprivate var prevGroupId: String?
    fileprivate var prevGroupTitle: [String]?
    fileprivate var prevDeviceId: String?
    fileprivate var prevPrice: String?
    fileprivate var prevExcludeSoldOut: Bool?
    fileprivate var prevSort: String?
    fileprivate var prevColor: [String]?
    fileprivate var prevCarrierName: [String]?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    init(itmData: SSTItemData) {
        super.init(searchData: itmData)
        
        for itm in itmData.items {
            if let nItm = SSTItem(JSON: itm.toJSON()) {
                self.items.append(nItm)
            }
        }
        
        self.categoryFacets.append(contentsOf: itmData.categoryFacets)
        self.colorsFacets.append(contentsOf: itmData.colorsFacets)
        self.carriersFacets.append(contentsOf: itmData.carriersFacets)
        
        self.prevKey = itmData.prevKey
        self.prevGroupId = itmData.prevGroupId
        self.prevGroupTitle = itmData.prevGroupTitle
        self.prevDeviceId = itmData.prevDeviceId
        self.prevPrice = itmData.prevPrice
        self.prevExcludeSoldOut = itmData.prevExcludeSoldOut
        self.prevSort = itmData.prevSort
    }
    
    func update(_ dict: NSDictionary) {
        if dict[kSearchDocs] != nil {
            self.numFound = validInt(dict[kSearchNumFound])
            self.start = validInt(dict[kSearchStart])
            
            if start == 0 {
                items.removeAll()
            }
            
            for mItem in validNSArray(dict[kSearchDocs]) {
                if let item = SSTItem(JSON: validDictionary(mItem)) {
                    items.append(item)
                }
            }
            
            var facetsDict = validDictionary(dict[kSearchFacets])
            
//            var categoryFacets = [Facet]()
//            var colorsFacets = [Facet]()
//            var carriersFacets = [Facet]()
            
            if let categoryFacetDict = facetsDict["gTitle2L"] {
                self.categoryFacets.removeAll()
                for (key,value) in validDictionary(categoryFacetDict) {
                    self.categoryFacets.append(Facet(key: validString(key), value: validInt(value), type: "", isExpanded: true))
                }
                self.categoryFacets.sort(by: { (facetA, facetB) -> Bool in
                    return facetA.key < facetB.key
                })
            }
            if let categoryFacetDict = facetsDict[kItemCarrierName] {
                self.carriersFacets.removeAll()
                for (key,value) in validDictionary(categoryFacetDict) {
                    self.carriersFacets.append(Facet(key: validString(key), value: validInt(value), type: "", isExpanded: true))
                }
                self.carriersFacets.sort(by: { (facetA, facetB) -> Bool in
                    return facetA.key < facetB.key
                })
            }

            if let categoryFacetDict = facetsDict[kItemColor] {
                self.colorsFacets.removeAll()
                for (key,value) in validDictionary(categoryFacetDict) {
                    self.colorsFacets.append(Facet(key: validString(key), value: validInt(value), type: "", isExpanded: true))
                }
                self.colorsFacets.sort(by: { (facetA, facetB) -> Bool in
                    return facetA.key < facetB.key
                })
            }
        } else {
            var itemsTmp = [SSTItem]()
            for mItem in validNSArray(dict[kNewArrivalsData]) {
                if let item = SSTItem(JSON: validDictionary(mItem)) {
                    itemsTmp.append(item)
                }
            }
            items = itemsTmp
        }
    }
    
    func update(_ array: Array<Any>) {
        items.removeAll()
        for mItem in array {
            if let item = SSTItem(JSON: validDictionary(mItem)) {
                items.append(item)
            }
        }
    }
    
    func searchItemsWithCategoryId(_ categoryId: String) {
        searchItems("\(kItemGroupId):\(categoryId)")
    }
    
    func searchItemsWithPrefix(_ keyword: String) {
        if keyword.isEmpty {
            return
        }
        
        biz.searchItemsWithPrefix(keyword, start: 0, rows: 100, sort: "", facet: "") { (data, error) in
            if error == nil {
                self.update(validNSDictionary(data))
                self.groups = self.groupItems()
                self.delegate?.refreshUI(self)
            } else {
                self.items.removeAll()
                self.delegate?.refreshUI(nil)
            }
        }
    }

    func searchItemsWithKeyword(_ keyword: String) {
        guard keyword.trim() != "" else {
            return
        }
        searchItems("\(keyword)")
    }
    
    func searchItems(_ key: String, groupId: String? = "", groupTitle: [String]? = nil, deviceId: String? = "", price: String? = "", excludeSoldOut: Bool? = false, start: Int = 0, rows: Int = kSearchItemPageSize, sort: String = "", facet: String = "0", color: [String]? = nil, carrierName: [String]? = nil, callback: RequestCallBack? = nil) {
        self.prevKey = key
        self.prevGroupId = groupId
        self.prevGroupTitle = groupTitle
        self.prevDeviceId = deviceId
        self.prevPrice = price
        self.prevExcludeSoldOut = excludeSoldOut
        self.prevSort = sort
        self.prevColor = color
        self.prevCarrierName = carrierName
       
        biz.searchItems(key, groupId: groupId, groupTitle: groupTitle, deviceId: deviceId, price: price, excludeSoldOut: excludeSoldOut, start: start, rows: rows, sort: sort, facet: facet, color: color, carrierName: carrierName) { (data, error) in
            if error == nil {
                self.update(validNSDictionary(data))
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(nil)
            }
            callback?(data, error)
        }
        
        if facet == "1" && key.isNotEmpty {
            insertHistoryKeywords([key])
        }
    }
    
    func searchItemsForNextPage(callback: RequestCallBack? = nil) {
        self.searchItems(validString(self.prevKey), groupId: self.prevGroupId, groupTitle: self.prevGroupTitle, deviceId: self.prevDeviceId, price: self.prevPrice, excludeSoldOut: self.prevExcludeSoldOut, start: self.items.count, rows: kSearchItemPageSize, sort: validString(self.prevSort), color: self.prevColor, carrierName: self.prevCarrierName) { data, error in
            callback?(data, error)
            self.delegate?.refreshUI(self)
        }
    }
    
    func getNewArrivals(_ callback: RequestCallBack? = nil) {
        biz.getNewArrivals { (data, error) in
            if error == nil {
                self.update(validArray(data))
            } else {
                self.items.removeAll()
            }
            self.delegate?.refreshUI(self)
        }
    }
    
    func getFeaturedProduct(_ callback: RequestCallBack? = nil) {
        biz.getFeaturedProduct { (data, error) in
            if error == nil {
                self.update(validArray(data))
            } else {
                self.items.removeAll()
            }
            self.delegate?.refreshUI(self)
        }
    }
    
    func fetchSegguestions(_ key: String) {
        biz.getSuggestions(key) { (data, error) in
            printDebug("suggest key: \(key)")
            if error == nil && data != nil {
                self.suggestions = validNSArray(validDictionary(data)[kSearchSuggestions]) as! [String]
                self.delegate?.refreshUI(self.suggestions)
            }
        }
    }
    
    // MARK: -- history keywords
    
    func refreshHistoryKeywords() {
        historyKeywords = getHistoryKeywords()
    }
    
    func insertHistoryKeywords(_ keywords: [String]) {
        var tHistoryKeywords = getHistoryKeywords()
        for keyword in keywords {
            if keyword.isEmpty {
                break
            }
            for ind in 0 ..< tHistoryKeywords.count {
                if keyword.lowercased().trim() == tHistoryKeywords[ind].lowercased().trim() {
                    tHistoryKeywords.remove(at: ind)
                    break
                }
            }
            tHistoryKeywords.insert(keyword, at: 0)
        }
        saveHistoryKeywords(tHistoryKeywords)
    }
    
    func appendHistoryKeywords(_ keywords: [String]) {
        var tHistoryKeywords = getHistoryKeywords()
        for keyword in keywords {
            var found = false
            for historyKey in tHistoryKeywords {
                if keyword == historyKey {
                    found = true
                    break
                }
            }
            if !found {
                tHistoryKeywords.append(keyword)
            }
        }
        saveHistoryKeywords(tHistoryKeywords)
    }
    
    func removeHistoryKeyword(_ keyword: String) {
        var tHistoryKeywords = getHistoryKeywords()
        for index in 0 ..< tHistoryKeywords.count {
            if keyword == tHistoryKeywords[index] {
                tHistoryKeywords.remove(at: index)
                saveHistoryKeywords(tHistoryKeywords)
                break
            }
        }
    }
    
    func removeAllHistory() {
        var tHistoryKeywords = getHistoryKeywords()
        tHistoryKeywords.removeAll()
        saveHistoryKeywords(tHistoryKeywords)
    }
    
    func saveHistoryKeywords(_ historyKeywords: [String]) {
        FileOP.archive(kSearchHistoryKeywordsFileName, object: historyKeywords)
        self.historyKeywords = historyKeywords
    }
    
    func getHistoryKeywords() -> [String] {
        if let keywords = FileOP.unarchive(kSearchHistoryKeywordsFileName) {
            return validArray(keywords) as! [String]
        }
        return [String]()
    }
    
    func groupItems() -> [SSTGroup] {
        var groups = [SSTGroup]()
        for item in items {
            var found = false
            for ind in 0 ..< groups.count {
                if item.groupTitle == groups[ind].name {
                    groups[ind].items.append(item)
                    found = true
                    break
                }
            }
            if !found {
                if validString(item.groupTitle).isNotEmpty {
                    groups.append(SSTGroup(name: item.groupTitle, itms: [item]))
                }
            }
        }
        return groups
    }
    
//    static func getSolrQ(_ keywords: [String]) -> String {
//        
//        var searchKeywords = [String]()
//        
//        for ind in 0 ..< keywords.count {
//            let splitedWords = keywords[ind].components(separatedBy: " ")
//            for jnd in 0 ..< splitedWords.count {
//                if splitedWords[jnd].trim() != "" {
//                    if ind > 0 {
//                        searchKeywords.append(" AND ")
//                    }
//                    searchKeywords.append("(\(splitedWords[jnd].trim()) \(splitedWords[jnd].trim())~)")
//                }
//            }
//        }
//        
//        return " _text_:(\(searchKeywords.joined(separator: " "))) "
//    }
    
    //缺货订阅
    static func saveStockNotifications(_ itemId: String, callback: @escaping (_ message: Any?) -> Void) {
        biz.saveStockNotification(itemId) { (data, error) in
            if error == nil {
                biz.stockRemindIds.updateValue(true, forKey: itemId)
                callback(200)
            } else {
                callback(error)
            }
        }
    }
    
    //取消订阅
    static func cancelStockNotification(_ itemId: String, callback:@escaping (_ message: Any?) -> Void ) {
        biz.deleteStockNotification(itemId) { (data, error) in
            if error == nil {
                biz.stockRemindIds.removeValue(forKey: itemId)
                callback(200)
            } else {
                callback(error)
            }
        }
    }
    
    //获取用户所有订阅的产品
    static func getStockNotifications() {
        guard biz.user.isLogined else {
            return
        }
        biz.getStockNotifications { (data, error) in
            if error == nil && data != nil {
                let ids = validArray(data)
                for itemId in ids {
                    let tmpId = validString(itemId)
                    biz.stockRemindIds.updateValue(true, forKey: tmpId)
                }
            }
        }
    }
}
