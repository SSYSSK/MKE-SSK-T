//
//  SSTPayResult.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/23/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTPayResult: BaseModel {
    
    var isSuccessful = false
    var msg: String!
    var type: SSTOrderPaymentType?
    
    override init() {
        super.init()
    }
    
    init(isSuccessful: Bool, msg: String, type: SSTOrderPaymentType?) {
        super.init()
        
        self.isSuccessful = isSuccessful
        self.msg = msg
        self.type = type
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }

}
