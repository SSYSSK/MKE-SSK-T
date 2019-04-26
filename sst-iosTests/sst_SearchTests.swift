//
//  sst_SearchTests.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import XCTest

@testable import sstDEV
import ObjectMapper

class sst_SearchTests: XCTestCase {
    
    func testSearchItems() {
        let expectation = self.expectation(description: "searchItemsWithKeyword")
        let itemData = SSTItemData()
        itemData.searchItemsWithKeyword("i")
        TaskUtil.delayExecuting(5) {
            for  i in 0 ..< itemData.items.count  {
                XCTAssertNotNil(itemData.items.count)
                XCTAssertNotNil(itemData.items[i].id)
                XCTAssertNotNil(itemData.items[i].name)
                XCTAssertNotNil(itemData.items[i].sku)
                XCTAssertNotNil(itemData.items[i].price)
                XCTAssertNotNil(itemData.items[i].groupId)
                XCTAssertNotNil(itemData.items[i].groupTitle)
            }
            if itemData.items.count > 0 {
                let groups = itemData.groupItems()
                XCTAssert(groups.count > 0, "The count of groups should be greater than 0.")
            }
            expectation.fulfill()
        }
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
    func testRemoveAllHistory() {
        let expectation = self.expectation(description: "removeAllHistory")
        let itemData = SSTItemData()
        itemData.removeAllHistory()
        TaskUtil.delayExecuting(3) {
            XCTAssertTrue(itemData.historyKeywords.count == 0)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
    func testAddHistory() {
        let expectation = self.expectation(description: "appendHistoryKeywords")
        let itemData = SSTItemData()
        itemData.appendHistoryKeywords(["ipon"])
        TaskUtil.delayExecuting(3) {
            XCTAssert(itemData.getHistoryKeywords().contains("ipon"))
            expectation.fulfill()
        }
        waitForExpectations(timeout: 20.0, handler:nil)
    }
}
