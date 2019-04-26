//
//  sst_OrderTests.swift
//  sst-ios
//
//  Created by Amy on 16/7/20.
//  Copyright © 2016年 SST. All rights reserved.
//

import XCTest
@testable import sstDEV

class sst_OrderTests: XCTestCase {
    
    func testSearchItemAndAddToCartAndCreatOrder() {
        let expectation = self.expectation(description: "Search Item, Add to Cart and Create Order")
        
        let user = SSTUser()
        user.email = "c@qq.com"
        user.password = "asdfed".sha512String
        user.login(user, callback: { (data, error) in
            XCTAssertNil(error)
            XCTAssertTrue(user.isLogined)
            
            biz.user = user

            let itemData = SSTItemData()
            itemData.searchItems("iphone")
            TaskUtil.delayExecuting(3, block: {
                XCTAssert(itemData.items.count > 0)
                
                if itemData.items.count > 0 {
                    let cart = SSTCart()
                    cart.addItem(itemData.items[0]) { data, error in
                        XCTAssertNil(error)
                        XCTAssertTrue(cart.items[0].itemId.isNotEmpty)
                        
                        SSTCart.fetchShippingInfoBeforePlacingOrder(itemsId: cart.itemIds, itemsTotal: cart.orderItemsTotal) { (data, error) in
                            XCTAssertNil(error)
                            
                            if error == nil {
                                let shippingDict = validDictionary(data)
                                
                                var lastMergableOrderShippingCompanyName = validString(shippingDict[kLastMergableOrderShippingCompany])
                                var mergableOrder: SSTOrder?
                                var billingAddr: SSTShippingAddress?
                                var shippingAddr: SSTShippingAddress?
                                var shippingCompanies: [SSTShippingCompany]!
                                
                                if let tOrder = SSTOrder(JSON: validDictionary(shippingDict[kLastMergableTargetOrder])) {
                                    mergableOrder = tOrder
                                }
                                
                                if let tBillingAddr = SSTShippingAddress(JSON: validDictionary(shippingDict[kDefaultBillingAddress])) {
                                    billingAddr = tBillingAddr
                                }
                                
                                if let tShippingAddr = SSTShippingAddress(JSON: validDictionary(shippingDict[kDefaultShippingAddress])) {
                                    shippingAddr = tShippingAddr
                                }
                                
                                var tShippingCompanies = [SSTShippingCompany]()
                                for item in validArray(shippingDict[kShippingCompany]) {
                                    if let tShippingCompany = SSTShippingCompany(JSON: validDictionary(item)) {
                                        tShippingCompanies.append(tShippingCompany)
                                    }
                                }
                                shippingCompanies = tShippingCompanies
                                
                                XCTAssertTrue(shippingCompanies.count > 0)
                                
                                let addressData = SSTAddressData()
                                addressData.getAddressList()
                                TaskUtil.delayExecuting(3, block: {
                                    XCTAssertTrue(addressData.addressList.count >= 2)
                                    shippingAddr = addressData.addressList[0]
                                    billingAddr = addressData.addressList[1]
                                    
                                    SSTCart.fetchLastmergableOrder(validString(shippingAddr!.id), itemsId: cart.itemIds, itemsTotal: cart.orderItemsTotal) { (data, error) in
                                        XCTAssertNil(error)
                                        
                                        if error == nil {
                                            let shippingDict = validDictionary(data)
                                            
                                            lastMergableOrderShippingCompanyName = validString(shippingDict[kLastMergableOrderShippingCompany])
                                            printDebug("\(lastMergableOrderShippingCompanyName) just for display on the page of Payment Options.")
                                            
                                            if let tOrder = SSTOrder(JSON: validDictionary(shippingDict[kLastMergableTargetOrder])) {
                                                mergableOrder = tOrder
                                            }
                                            
                                            var tShippingCompanies = [SSTShippingCompany]()
                                            for item in validArray(shippingDict[kShippingCompany]) {
                                                if let tShippingCompany = SSTShippingCompany(JSON: validDictionary(item)) {
                                                    tShippingCompanies.append(tShippingCompany)
                                                }
                                            }
                                            shippingCompanies = tShippingCompanies
                                        }
                                        
                                        SSTOrder.precalculateOrderPrice(
                                            itemIds: cart.itemIds,
                                            orderPaymentId: "",
                                            mergeShippingTargeOrderId: "",
                                            mergeShippingId: "",
                                            mergeShippingRemarks: "",
                                            discountRequestFlag: false,
                                            billingAddressId: validString(billingAddr!.id),
                                            shippingAddressId: validString(shippingAddr!.id),
                                            shippingCompanyId: validString(shippingCompanies[0].id),
                                            customerShippingAcc: "")
                                        { (data, error) in
                                            XCTAssertNil(error)
                                            
                                            if let pendingOrder = data as? SSTOrder {
                                                pendingOrder.shippingAddress = shippingAddr
                                                pendingOrder.billingAddress = billingAddr
                                                pendingOrder.shippingCompany = shippingCompanies[0]
                                                pendingOrder.shippingCompanyName = shippingCompanies[0].name
                                                
                                                if mergableOrder?.id != nil {
                                                    pendingOrder.shippingCompanyName = lastMergableOrderShippingCompanyName
                                                }
                                                
                                                let paymentTypeData = SSTPaymentTypeData()
                                                paymentTypeData.getPaymentType(validString(pendingOrder.shippingAddress!.stateCode), codOrderPrice: pendingOrder.orderFinalTotal, shippingCompanyId: validString(pendingOrder.shippingCompany?.id), orderId: pendingOrder.id, mergeTargetOrderPaymentId: 2)
                                                TaskUtil.delayExecuting(3, block: {
                                                    XCTAssertTrue(paymentTypeData.paymentTypes.count > 0)
                                                    
                                                    SSTOrder.createOrder(
                                                        itemIds:cart.itemIds,
                                                        billingAddressId: validString(pendingOrder.billingAddress?.id),
                                                        shippingAddressId: validString(pendingOrder.shippingAddress?.id),
                                                        shippingCompanyId: validString(pendingOrder.shippingCompany?.id),
                                                        orderPaymentId:validString(paymentTypeData.paymentTypes[0].paymentId),
                                                        orderNote: "Order Note from Auto Test",
                                                        discountFlag: false,
                                                        mergeOrderId: validString(mergableOrder?.id),
                                                        mergeShippingTargetShippingId: "",
                                                        mergeShippingRemarks: "Shipping Remarks from Auto Test", useWalletAmount: 0, customerShippingAcc: "")
                                                    { (data, error) in
                                                        XCTAssertNil(error)
                                                        
                                                        if error == nil {
                                                            if let orderGenerated = data as? SSTOrder {
                                                                XCTAssertNotNil(orderGenerated.id)
                                                                XCTAssertTrue(orderGenerated.orderFinalTotal > 0)
                                                                XCTAssertTrue(orderGenerated.items.count == cart.itemIds.count)
                                                                
                                                                expectation.fulfill()
                                                            }
                                                        }
                                                    }
                                                })
                                            }
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            })
        })
        
        waitForExpectations(timeout: 30, handler:nil)
    }
    
    func testSearchOrderAndGetOrderDetail() {
        let expectation = self.expectation(description: "Search Order and Get Order Detail")
        
        let user = SSTUser()
        user.email = "c@qq.com"
        user.password = "asdfed".sha512String
        user.login(user, callback: { (data, error) in
            XCTAssertNil(error)
            XCTAssertTrue(user.isLogined)
            
            biz.user = user
            let orderData = SSTOrderData()
            orderData.searchOrders(status: "all")
            TaskUtil.delayExecuting(3) {
                XCTAssert(orderData.orders.count > 0)
                if orderData.orders.count > 0 {
                    if orderData.orders.count > 1 {
                        XCTAssert(orderData.orders[0].id.compare(orderData.orders[1].id) == .orderedDescending)
                    }
                    SSTOrder.fetchOrder(orderData.orders[0].id, callback: { (data, error) in
                        XCTAssertNil(error)
                        XCTAssertNotNil(data)
                        if error == nil {
                            let order = data as! SSTOrder
                            XCTAssert(order.orderFinalTotal == orderData.orders[0].orderFinalTotal)
                        }
                        expectation.fulfill()
                    })
                }
            }
        })
        
        waitForExpectations(timeout: kTimeoutForTest, handler:nil)
    }
    
}
