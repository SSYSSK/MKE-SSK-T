//
//  SSTDevices.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kDeviceId             = "deviceId"
let kDeviceName           = "deviceName"
let kDeviceImage          = "deviceImage"

class SSTDevices: BaseModel {
    
    var deviceId : Int!
    var deviceName: String!
    var imgUrl: String?
    
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        deviceId          <- map[kDeviceId]
        deviceName        <- map[kDeviceName]
        imgUrl            <- map[kDeviceImage]
    }
}
