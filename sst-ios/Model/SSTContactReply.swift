//
//  SSTContactReply.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

class SSTContactReply: BaseModel {
    
    var contentType: Int?
    var content: String?
    var thumbnail: String?
    var imgUrl: String?
    var dateCreated: Date?
    var userType: Int?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    var isMyself: Bool {
        get {
            return userType == 0
        }
    }
    
    var isMessage: Bool {
        get {
            return contentType == 0
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        contentType     <- map["replyType"]
        content         <- map["reply"]
        thumbnail       <- map["reply"]
        imgUrl          <- map["originalPicture"]
        dateCreated     <- (map["createDate"],transformStringToDate)
        userType        <- map["createByType"]
    }

}
