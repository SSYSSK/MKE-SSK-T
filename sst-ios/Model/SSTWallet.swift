//
//  SSTWallet.swift
//  sst-ios
//
//  Created by Amy on 2017/3/22.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kWalletDetailId     = "detailId"
let kWalletBeginAmount  = "beginAmount"
let kWalletEndAmount    = "endAmount"
let kWalletDate         = "actDate"
let kWalletType         = "actType"
let kWalletRemark       = "remarks"

class SSTWallet: BaseModel {

    var detailId: String?
    var userId: String?
    var beginAmount: Double?
    var endAmount: Double?
    var actType: Int = 0
    var date: Date?
    var orderId: String?
    var remark: String?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        detailId    <- map[kWalletDetailId]
        beginAmount <- map[kWalletBeginAmount]
        endAmount   <- map[kWalletEndAmount]
        actType     <- map[kWalletType]
        date        <- (map[kWalletDate],transformStringToDate)
        orderId     <- (map[kOrderId],transformIntToString)
        remark      <- map[kWalletRemark]
    }
   
}
