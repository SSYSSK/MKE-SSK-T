//
//  SSTShippingAddress.swift
//  sst-ios
//
//  Created by Amy on 16/6/28.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kSAddressId   = "addrId"
let kSCompanyName = "company"
let kSAddressName = "addrName"
let kSFisrstName  = "firstName"
let kSLastName    = "lastName"
let kSCity        = "city"
let kSState       = "stateName"
let kSStateCode   = "state"
let kSCountry     = "countryName"
let kSCountryCode = "country"
let kSZip         = "zip"
let kSPhone       = "phone"
let kSPhone2      = "phone2"
let kSPhone3      = "phone3"
let kSAptAddress  = "address"
let kSEmail       = "email"

let kOAddressId   = "oaId"
let kOCompanyName = "oaCompany"
let kOCity        = "oaCity"
let kOState       = "oaStateName"
let kOStateCode   = "oaState"
let kOCountry     = "oaCountryName"
let kOCountryCode = "oaCountry"
let kOZip         = "oaZip"
let kOPhone       = "oaPhone"
let kOPhone2      = "oaPhone2"
let kOPhone3      = "oaPhone3"
let kOAptAddress  = "oaAddress"
let kOEmail       = "oaEmail"
let kOMAddressId  = "memberAddressId"

class SSTShippingAddress: BaseModel {
    
    var id: String?
    var companyName: String?
    var firstName: String?
    var lastName: String?
    var city: String?
    var state: String?
    var stateCode: String?
    var countryName: String?
    var countryCode: String?
    var zip: String?
    var phone: String?
    var phone2: String?
    var phone3: String?
    var apt: String?        // 详细地址，比如街道门牌号
    var email: String?
    
    var isPrimary = false   // 是否设置为primary
    var isBilling = false   // 是否设置为billing
    var isShipping = false  // 是否设置为shipping
    
    var addressName: String? //地址名称（相当于别名）
    var isSelected = false  //从 order confirm过来，是否选则该地址的属性
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
//        if validString(map.JSON[kSAddressId]) == "" && validString(map.JSON[kOMAddressId]) == "" && validString(map.JSON[kOAddressId]) == "" {
//            return nil
//        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        firstName   <- map[kSFisrstName]
        lastName    <- map[kSLastName]
        
        if map.JSON[kSAddressId] != nil {
            id          <- (map[kSAddressId], transformIntToString)
            companyName <- map[kSCompanyName]
            city        <- map[kSCity]
            state       <- map[kSState]
            stateCode   <- map[kSStateCode]
            countryName <- map[kSCountry]
            countryCode <- map[kSCountryCode]
            zip         <- map[kSZip]
            phone       <- map[kSPhone]
            phone2      <- map[kSPhone2]
            phone3      <- map[kSPhone3]
            apt         <- map[kSAptAddress]
            addressName <- map[kSAddressName]
            email       <- map[kSEmail]
        } else {
            id          <- (map[kOMAddressId], transformIntToString)
            companyName <- map[kOCompanyName]
            city        <- map[kOCity]
            state       <- map[kOState]
            stateCode   <- map[kOStateCode]
            countryName <- map[kOCountry]
            countryCode <- map[kOCountryCode]
            zip         <- map[kOZip]
            phone       <- map[kOPhone]
            phone2      <- map[kOPhone2]
            phone3      <- map[kOPhone3]
            apt         <- map[kOAptAddress]
            email       <- map[kOEmail]
        }
    }
    
    //    func updateAddress(info: SSTShippingAddress, callback:(message: AnyObject?) -> Void) {
    //        biz.updateAdderss(info) { (data, error) in
    //            if nil == error {
    //                var items = [SSTShippingAddress]()
    //                for itmDict in validNSArray(data) {
    //                    if let item = SSTShippingAddress(JSON: validDictionary(itmDict)) {
    //                        items.append(item)
    //                    }
    //                }
    //                self.delegate?.refreshUI(self)
    //                callback(message: 200)
    //
    //            } else {
    //                callback(message: error )
    //            }
    //        }
    //    }
    //
    //    func addAddress(info: SSTShippingAddress, callback:(message: AnyObject?) -> Void) {
    //        biz.addAddress(info) { (data, error) in
    //            if nil == error {
    //                callback(message: 200)
    //            } else {
    //                callback(message: error )
    //            }
    //        }
    //    }
}

