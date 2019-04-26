//
//  SSTCodRecordsData.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

class SSTCodRecordsData: BaseModel {
    var codRecords = [SSTCodRecord]()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.setCodRecords(validNSArray(map.JSON))
        
    }
    
    func setCodRecords(_ arr: NSArray) {
        
        for fileDict in arr {
            if let codRecord = SSTCodRecord(JSON: validDictionary(fileDict)) {
             codRecords.append(codRecord)
            }
        }
    }

    
    func update(_ array: Array<AnyObject>) {
        codRecords.removeAll()
        self.setCodRecords(array as NSArray)
       
        self.delegate?.refreshUI(self)
    }
    
    func getApplyCodRecords() {
        
        biz.getApplyCodRecords() { (data, error) in
            if data != nil {
                self.update(validArray(data))
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func getApplyTAXRecords() {
        
        biz.getApplyTaxRecords() { (data, error) in
            if data != nil {
                self.update(validArray(data))
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
}
