//
//  SSTMessage.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kMessageMsgid              = "msgid"
let kMessageTitle              = "title"
let kMessageType               = "type"
let kMessageContent            = "content"
let kMessageStatus             = "status"
let kMessageUpdateDateDate     = "updateDate"
let kMessageValue              = "detail"

class SSTMessage: BaseModel {
    
    var msgid: Int?
    var title: String?
    var type: Int!
    var content: String?
    var status: Int?
    var createDate: Date?
    var value: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        msgid         <- map[kMessageMsgid]
        title         <- map[kMessageTitle]
        type          <- map[kMessageType]
        content       <- map[kMessageContent]
        status        <- map[kMessageStatus]
        createDate    <-  (map["\(kMessageUpdateDateDate)"], transformStringToDate)
        value         <- map[kMessageValue]
    }
}
