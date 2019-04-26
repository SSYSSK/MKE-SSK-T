//
//  SST_Address.swift
//  sst-ios
//
//  Created by Amy on 16/9/26.
//  Copyright © 2016年 SST. All rights reserved.
//

import XCTest
@testable import sstDEV

class sst_UserTests: XCTestCase {
    
    func testRegisterAndUpdatePassword() {
        let expectation = self.expectation(description: "User Register, Update Password")
        
        let toRegisterUser = SSTUser()
        toRegisterUser.firstName = "Zal Test"
        toRegisterUser.email = "test_\(RandomUtil.randomInt(9999))@qq.com"
        toRegisterUser.password = "asdfef".sha512String
        SSTUser.register(toRegisterUser) { data, error in
            XCTAssertNil(error)
            
            if let user = data as? SSTUser {
                user.updatePassword("asdfef".sha512String, newPassword: "asdfed", callback: { (data, error) in
                    XCTAssertNil(error)
                    
                    expectation.fulfill()
                })
            }
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
    
    func testLoginAndLogout() {
        let expectation = self.expectation(description: "User Login, Update Password and Logout")
        
        let user = SSTUser()
        user.email = "c@qq.com"
        user.password = "asdfed".sha512String
        user.login(user, callback: { (data, error) in
            XCTAssertNil(error)
            XCTAssertTrue(user.isLogined)
            
            user.logout({ (data, error) in
                XCTAssertNil(error)
                XCTAssert(user.isLogined == false)
                
                expectation.fulfill()
            }, errorCallback: {_ in
                return true
            })
        })
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
    
    func testAddress() {
        let expectation = self.expectation(description: "Address")
        
        let addInfo = SSTShippingAddress()
        addInfo.id = "124"
        addInfo.companyName = "for test"
        addInfo.firstName = "Amy"
        addInfo.lastName = "He"
        addInfo.city = "Shenzhen"
        addInfo.state = "GuangDong"
        addInfo.stateCode = "GD"
        addInfo.countryName = "China"
        addInfo.countryCode = "CN"
        addInfo.apt = "North. 1"
        addInfo.zip = "10087"
        addInfo.phone = "040Ω8524844"
        addInfo.addressName = "office_\(Date().format())"
        
        SSTAddressData.addAddress(addInfo) { message in
            XCTAssert(validInt(message) == 200, "fail to add address")
            
            let addressData = SSTAddressData()
            addressData.getAddressList()
            TaskUtil.delayExecuting(3) {
                let cnt = addressData.addressList.count
                XCTAssertTrue(addressData.addressList.count > 0)
                
                if let address = addressData.addressList.first {
                    address.addressName = "\(validString(address.addressName))_updated"
                    SSTAddressData.updateAddress(address, callback: { (message) in
                        XCTAssert(validInt(message) == 200, "fail to update address")
                        
                        addressData.deleteAddress(validString(address.id))
                        TaskUtil.delayExecuting(3, block: {
                            XCTAssertTrue(addressData.addressList.count + 1 == cnt)
                            
                            expectation.fulfill()
                        })
                    })
                }
            }
        }
        
        waitForExpectations(timeout: 20.0, handler: nil)
    }
    
}
