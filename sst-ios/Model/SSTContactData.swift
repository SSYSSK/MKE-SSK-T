//
//  SSTContactData.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kContactHasNew = "questionReplyHasNew"

class SSTContactData: BaseModel {

    var records = [SSTContactRecord]()
    
    func update(array: Array<Any>) {
        var tRecords = [SSTContactRecord]()
        for rd in array {
            if let tR = SSTContactRecord(JSON: validDictionary(rd)) {
                tRecords.append(tR)
            }
        }
        self.records = tRecords
    }
    
    func fetchData() {
        biz.getContactData() { (data, error) in
            if error == nil && data != nil {
                self.update(array: validArray(data))
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }
    
    static func addRecord(title: String, content: String, files: [UIImage], callback: @escaping RequestCallBack) {
        biz.addContactRecord(title: title, content: content, files: files) { (data, error) in
            callback(data, error)
        }
    }
    
    static func getStatus(callback: RequestCallBack? = nil) {
        biz.getContactStatus { (data, error) in
            callback?(data, error)
        }
    }
}
