//
//  SSTMessageData.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kData               = "data"
let kNumFound           = "slides"
let kStart              = "newArrivals"
let kList               = "list"
let kPage               = "page"
let kMessageStartRow    = "startRow"
let kMessagePageNum     = "pageNum"
let kTotal              = "total"
let kHasNew             = "hasNew"

class SSTMessageData: BaseModel {
    
    var start = 0
    var numFound = 0
    var hasNew = false

    var messages = [SSTMessage]()
    
    func update(_ dict: Dictionary<String, Any>) {
        self.numFound = validInt(validDictionary(dict[kPage])[kTotal])
        self.start = validInt(validDictionary(dict[kPage])[kMessageStartRow])
        self.hasNew = validBool(dict[kHasNew])
        
        if start == 0 {
            messages.removeAll()
        } else {
            while messages.count >= start { // note: start is from 1 by watching API return data
                messages.removeLast()
            }
        }
        
        for mItem in validNSArray(validDictionary(dict[kPage])[kList]) {
            if let item = SSTMessage(JSON: validDictionary(mItem)) {
                messages.append(item)
            }
        }
    }

    func refreshUI() {
        self.delegate?.refreshUI(self)
    }
    
    func fetchData(start: Int = 0, rows: Int = 10, callback: RequestCallBack? = nil) {
        let pageNum = start / rows + 1
        biz.getHomeMessage(pageNum: pageNum, rows: rows) { (data, error) in
            if error == nil {
                self.update(validDictionary(data))
            }
            self.refreshUI()
            callback?(data, error)
        }
    }
    
    func saveMessageRecord(callback: RequestCallBack? = nil) {
        biz.saveMessageRecord() { (data, error) in
            callback?(data, error)
        }
    }
    
    func fetchMessage(msgId: String, callback: RequestCallBack? = nil) {
        biz.getMessage(msgId: msgId) { data, error in
            if error == nil, let msg = SSTMessage(JSON: validDictionary(data)) {
                callback?(msg, nil)
            } else {
                callback?(nil, error)
            }
        }
    }
}
