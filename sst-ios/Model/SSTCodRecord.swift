//
//  SSTCodRecords.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kCodRecordApplyId     = "applyid"
let kCodRecordCreateBy   = "createBy"
let kCodRecordApplystatus    = "applystatus"
let kCodRecordApplyRemarks     = "remarks"
let kCodRecordApplyCreateDate     = "createDate"
let kCodRecordApplyTitle     = "title"
//fileflag=0 add file
//fileflag=1 delete file
//fileflag=2 update file

let kCodRecordApplyEvent     = "fileflag"


class SSTCodRecord: BaseModel {
    
    var applyid: Int!
    var createBy: String = ""
    var applystatus: Int = -1
    var remarks: String = ""
    var createDate: Date?
    var event: Int = -1
    var name: String = ""
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        applyid          <- map[kCodRecordApplyId]
        createBy         <- (map[kCodRecordCreateBy],transformIntToString)
        applystatus      <- map[kCodRecordApplystatus]
        remarks          <- map[kCodRecordApplyRemarks]
        createDate       <- (map["\(kCodRecordApplyCreateDate)"], transformStringToDate)
        event            <- map[kCodRecordApplyEvent]
        name            <- map[kCodRecordApplyTitle]
        if applyid == nil {
            applyid = -1
        }
    }

}
