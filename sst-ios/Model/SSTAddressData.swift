//
//  SSTShippingAddressData.swift
//  sst-ios
//
//  Created by Amy on 16/6/28.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kAddressKey    = "addresses"
let kPrimaryAddrId = "primaryAddressId"
let kBillingAddrId = "billingAddressId"
let kShippingAddrId = "shippingAddressId"

let kAddressCityName    = "cityName"
let kAddressStateName   = "stateName"

class SSTAddressData: BaseModel {
    
    var addressList = [SSTShippingAddress]()
    var defaultPrimary: SSTShippingAddress?
    var defaultBilling: SSTShippingAddress?
    var defaultShipping: SSTShippingAddress?
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func updatedata (_ data: AnyObject) {
        let primaryAddId = validString(validDictionary(data)[kPrimaryAddrId])
        let billingAddId = validString(validDictionary(data)[kBillingAddrId])
        let shippingAddId = validString(validDictionary(data)[kShippingAddrId])
        
        var items = [SSTShippingAddress]()
        for itmDict in validNSArray(validDictionary(data)[kAddressKey]) {
            if let item = SSTShippingAddress(JSON: validDictionary(itmDict)) {
                items.append(item)
                if item.id == primaryAddId {
                    item.isPrimary = true
                    self.defaultPrimary = item
                }
                if item.id == billingAddId {
                    item.isBilling = true
                    self.defaultBilling = item
                }
                if item.id == shippingAddId {
                    item.isShipping = true
                    self.defaultShipping = item
                }
            }
        }
        self.addressList = items
    }
    
    func getAddressList() {
        biz.getAddressList { (data, error) in
            if nil == error && data != nil {
                self.updatedata(data! as AnyObject)
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
                SSTToastView.showError(validString(error))
            }
        }
    }

    func getDefaultPrimaryAddress() {
        biz.getDefaultPrimaryAddress { (data, error) in
            if nil == error {
                let info = SSTShippingAddress(JSON: validDictionary(data))
                self.defaultPrimary = info
                self.delegate?.refreshUI(info)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func getDefaultBillingAddress() {
        biz.getDefaultBillingAddress { (data, error) in
            if nil == error {
                let info = SSTShippingAddress(JSON: validDictionary(data))
                self.defaultBilling = info
                self.delegate?.refreshUI(info)
            } else {
                SSTToastView.showError(validString(error))
            }

        }
    }
    
    func getDefaultShippingAddress() {
        biz.getDefaultShippingAddress { (data, error) in
            if nil == error {
                let info = SSTShippingAddress(JSON: validDictionary(data))
                self.defaultShipping = info
                self.delegate?.refreshUI(info)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func deleteAddress(_ addressId: String) {
        biz.deleteAddress(addressId) { (data, error) in
            if nil == error, let tmpData = data {
                self.updatedata(tmpData as AnyObject)
                self.delegate?.refreshUI(self)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func setDefaultPrimaryAddress(_ addressId: String ) {
        biz.setDefaultPrimaryAddress(addressId) { (data, error) in
            if nil == error, let tmpData = data {
                self.updatedata(tmpData as AnyObject)
                self.delegate?.refreshUI(self)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func setDefaultBillingAddress(_ addressId: String) {
        biz.setDefaultBillingAddress(addressId) { (data, error) in
            if nil == error, let tmpData = data {
                self.updatedata(tmpData as AnyObject)
                self.delegate?.refreshUI(self)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func setDefaultShippingAddress(_ addressId: String) {
        biz.setDefaultShippingAddress(addressId) { (data, error) in
            if nil == error, let tmpData = data {
                self.updatedata(tmpData as AnyObject)
                self.delegate?.refreshUI(self)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    static func updateAddress(_ info: SSTShippingAddress, callback:@escaping (_ message: AnyObject?) -> Void) {
        biz.updateAdderss(info) { (data, error) in
            if nil == error {
                var items = [SSTShippingAddress]()
                for itmDict in validNSArray(data) {
                    if let item = SSTShippingAddress(JSON: validDictionary(itmDict)) {
                        items.append(item)
                    }
                }
//                self.delegate?.refreshUI(self)
                callback(200 as AnyObject?)
                
            } else {
                callback(error as AnyObject? )
            }
        }
    }
    
    static func addAddress(_ info: SSTShippingAddress, callback:@escaping (_ message: AnyObject?) -> Void) {
        biz.addAddress(info) { (data, error) in
            if nil == error {
                callback(200 as AnyObject?)
            } else {
                callback(error as AnyObject? )
            }
        }
    }
    
    static func getCityAndState(countryCode: String, postalCode: String, callback: @escaping RequestCallBack) {
        biz.getCityAndState(countryCode: countryCode, postalCode: postalCode) { (data, error) in
            callback(data, error)
        }
    }

}
