//
//  SSTUser.swift
//  sst-ios
//
//  Created by Amy on 16/8/16.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kUserFirstName = "firstName"
let kUserEmail     = "userEmail"
let kUserId        = "userId"
let kUserToken     = "userToken"
let kUserGuid      = "userGuid"
let kUserAlternativeEmail = "alternativeEmail"
var gIsShowingDailyShippingTip = false

class SSTUser: BaseModel {
    
    var firstName: String?
    var email: String?
    var alternativeEmail: String?
    var password: String?
    var id: String?
    var token: String?
    var type = false    // true:user, false: guest
    var guid: String?
    
    var activeSeconds: UInt64 = 0   // seconds of online active, it would set zero when user logined or app enter front again.
    
    var isLogined: Bool {
        get {
            if validString(token) != "" && validBool(type) == true {
                return true
            }
            return false
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    @objc func timerAlarm() {
        self.activeSeconds += 1
        
        if self.isLogined && self.activeSeconds % ( 5 * 60 ) == 0 { // show tip every five minutes when logined
            SSTDealsData.getDailyShipppingTip(callback: { (data, error) in
                if validString(data).isNotEmpty && gIsShowingDailyShippingTip == false {
                    let alertView = SSTAlertView(title: nil, message: validString(data))
                    alertView.addButton("OK") {
                        gIsShowingDailyShippingTip = false
                    }
                    gIsShowingDailyShippingTip = true
                    alertView.show()
                }
            })
        }
    }
    
    func updateGuestToken(_ callback: RequestCallBack? = nil) {
        biz.getGuestToken({ (data, error) in
            if nil == error {
                self.token = validString(data)
                self.type = false
                FileOP.archive(kUserFileName, object: self.toJSON())
            }
            printDebug("guest token = \(validString(data))")
            callback?(data, error)  
        })
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
        
        firstName <- map[kUserFirstName]
        email     <- map[kUserEmail]
        alternativeEmail <- map[kUserAlternativeEmail]
        id        <- (map[kUserId],transformIntToString)
        token     <- map[kUserToken]
        type      <- map[kUserTokenType]
        guid      <- map[kUserGuid]
    }
    
    func update(_ data: Dictionary<String,AnyObject>) {
        mapping(map: Map(mappingType: .fromJSON, JSON: data))
        self.delegate?.refreshUI(self)
    }
    
    func login(_ userInfo: SSTUser, callback: @escaping RequestCallBack) {
        biz.login(userInfo) { (data, error) in
            if error == nil {
                self.update(validDictionary(data))
                self.type = true
                FileOP.archive(kUserFileName, object: self.toJSON())
                
                self.activeSeconds = 0
                
                biz.cart.fetchData()
                callback(self, nil)
            } else {
                callback(nil, error)
            }
        }
    }
    
    static func register(_ userInfo: SSTUser, callback: @escaping RequestCallBack) {
        biz.register(userInfo) { (data, error) in
            if error == nil {
                if let user = SSTUser(JSON: validDictionary(data)) {
                    user.type = true
                    FileOP.archive(kUserFileName, object: user.toJSON())
                    biz.user = user
                    callback(user, nil)
                }
            } else {
                callback(nil, error)
            }
        }
    }
    
    func logout(_ callback: @escaping RequestCallBack, errorCallback: @escaping ErrorCallBack) {
        biz.signOut(self, callback: { (data, error) in
            if error == nil {
                self.token = validString(validDictionary(data)["guestToken"])
                self.type = false
                self.id = nil
                self.guid = nil
                FileOP.archive(kUserFileName, object: self.toJSON())
                biz.stockRemindIds.removeAll()
            }
            callback(data, error)
        }) { (errorCode) in
            if validBool(errorCode) == true {
                _ = errorCallback(true)
            }
            return true
        }
    }
    
    func getVerification(_ email: String ,callback:@escaping (_ message: AnyObject?) -> Void){
        biz.getVerificationCode(email) { (data, error) in
            if error == nil {
                callback(200 as AnyObject?)
            } else {
                callback(error as AnyObject?)
            }
        }
    }
    
    func updatePasswordByVerificationCode(_ email: String, password: String, code: String, callback: @escaping RequestCallBack) {
        biz.updatePasswordByVerificationCode(email, password: password, code: code) { (data, error) in
            if data != nil {
                callback(data,error)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func updatePassword(_ oldPassword: String, newPassword: String, callback: @escaping RequestCallBack) {
        biz.changePassword(user: self, oldPassword: oldPassword, newPassword: newPassword) { (data, error) in
            callback(data, error)
        }
    }
    
    func updateFirstName(newName: String, callback: @escaping RequestCallBack) {
        biz.updateFirstName(newName) { (data, error) in
            if error == nil {
                self.firstName = newName
                FileOP.archive(kUserFileName, object: self.toJSON())
            }
            callback(data, error)
        }
    }
}

