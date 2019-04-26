//
//  SSTOrderList.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/14/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kOrdersNumFound   = "total"
let kOrderUnpaidNum   = "unpaid"
let kOrderInProcess   = "unshipped"
let kOrderInTransit   = "unreceived"

let kOrderDefaultSeachSort = "createDate DESC"

class SSTOrderData: SSTSearchData {
    
    var orders = [SSTOrder]()
    var unpaidNums: Int = 0
    var inProcess: Int = 0
    var inTransit: Int = 0
    
    func update(_ dict: NSDictionary) {
        self.numFound = validInt(dict[kSearchNumFound])
        self.start = validInt(dict[kSearchStart])
        
        if start == 0 {
            orders.removeAll()
        }
        
        for mOrder in validNSArray(dict[kSearchDocs]) {
            if let order = SSTOrder(JSON: validDictionary(mOrder)) {
                orders.append(order)
            }
        }
    }
    
    func searchOrders(status: String, key: String = "*", start: Int = 0, rows: Int = kSearchItemPageSize, sort: String = kOrderDefaultSeachSort, callback: RequestCallBack? = nil) {
        var sort = kOrderDefaultSeachSort
        if key != "" && key != "*" {
            sort = ""
        }
        biz.searchOrders(status: status, keyword: key, start: start, rows: rows, sort: sort) { (data, error) in
            if error == nil {
                self.update(validNSDictionary(data))
                if callback == nil {
                    self.delegate?.refreshUI(self)
                } else {
                    callback?(self, nil)
                }
            } else {
                if callback == nil {
                    self.delegate?.refreshUI(error)
                } else {
                    callback?(nil, error)
                }
            }
        }
    }
    
    func getOrderNumbers() {
        biz.getOrderNumbers { (data, error) in
            if nil == error {
                let dataDict = validNSDictionary(data)
                    self.unpaidNums = validInt(dataDict[kOrderUnpaidNum])
                    self.inProcess = validInt(dataDict[kOrderInProcess])
                    self.inTransit = validInt(dataDict[kOrderInTransit])
                    self.delegate?.refreshUI(self)
            }
        }
    }
    
    func resetOrderNumbers() {
        self.unpaidNums = 0
        self.inProcess = 0
        self.inTransit = 0
        self.delegate?.refreshUI(self)
    }

}
