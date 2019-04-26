//
//  cartTests.swift
//  sst-ios
//
//  Created by Zal Zhang on 7/15/16.
//  Copyright © 2016 SST. All rights reserved.
//

import XCTest
@testable import sstDEV

class sst_CartTests: XCTestCase {
    
    func testItemCUDInCart() {
        let expectation = self.expectation(description: "Add, Update, Remove Item in Cart")
        
        let itemData = SSTItemData()
        itemData.searchItems("i")
        TaskUtil.delayExecuting(3, block: {
            XCTAssert(itemData.items.count > 0)
            
            if itemData.items.count > 0 {
                let cart = SSTCart()
                cart.addItem(itemData.items[0], addingQty: 20) { data, error in
                    XCTAssertNil(error)
                    XCTAssertTrue(cart.items[0].itemId.isNotEmpty)
                    XCTAssertTrue(cart.items.count >= 1)
                    
                    if cart.items.count == 1 {
                        XCTAssertTrue(cart.items[0].id == itemData.items[0].id)
                    }
                    
                    let qty = cart.qty
                    cart.updateItems(itms: [cart.items[0]], addingQtys: [10]) { data, error in
                        XCTAssertNil(error)
                        XCTAssertTrue(cart.qty == qty + 10)
                        
                        cart.updateItem(cart.items[0], addingQty: -3, callback: { (data, error) in
                            XCTAssertNil(error)
                            XCTAssertTrue(cart.qty == qty + 7)
                            
                            cart.removeItems([cart.items[0].id], callback: { (data, error) in
                                XCTAssertNil(error)
                                XCTAssertTrue(cart.qty == 0)
                                
                                expectation.fulfill()
                            })
                        })
                    }
                }
            }
        })
        
        waitForExpectations(timeout: kTimeoutForTest, handler: nil)
    }
    
}
