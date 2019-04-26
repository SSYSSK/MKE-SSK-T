//
//  sst_HomeTests.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import XCTest
@testable import sstDEV

class sst_HomeTests: XCTestCase {
    
    func testGetHomePage() {
        let expectation = self.expectation(description: "Fetch Home Data")
        
        let homeData = SSTHomeData()
        homeData.fetchData()
        TaskUtil.delayExecuting(5) { 
            XCTAssertNotNil(homeData.banners)
            XCTAssertNotNil(homeData.slides)
            XCTAssertNotNil(homeData.newArrivals)
            XCTAssertNotNil(homeData.featureProducts)
            XCTAssertNotNil(homeData.dailyDeals)

            expectation.fulfill()
        }
        waitForExpectations(timeout: 20.0, handler:nil)
    }
    
    
}
