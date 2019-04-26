//
//  SSTDealMessage.swift
//  sst-ios
//
//  Created by Amy on 2016/10/25.
//  Copyright © 2016年 SST. All rights reserved.

import UIKit

let kDealMessage = "content"

class SSTDealMessage: BaseModel {
    
    var msgs = [String]()
    
    fileprivate func update(_ array: Array<AnyObject>) {
        var msgArray = [String]()
        for ar in array {
            let dict = validDictionary(ar)
            if dict[kDealMessage] != nil {
                msgArray.append(validString(dict[kDealMessage]))
            }
        }
        msgs = msgArray
    }
    
    static func toAttributedString(_ msg: String, color: String = "#FFFFFF") -> NSAttributedString {
        return "<span style=\"color:\(color)\";>\(msg)</span>".toAttributedString(font: UIFont.boldSystemFont(ofSize: 12))
    }
    
    func getDealMessage() {
        biz.getDealMessage { (data, error) in
            if data != nil {
                self.update(validArray(data))
            }
        }
    }
}
