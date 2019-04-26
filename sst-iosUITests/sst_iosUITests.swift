//
//  sst_iosUITests.swift
//  sst-iosUITests
//
//  Created by Liang Zhang on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import XCTest

let kHomeFeatureProductsItemName = "Motorola Moto X+1 X2 X(2014) XT1092 XT1093 XT1094 XT1095 XT1096 XT1097 LCD Screen Display with Digitizer Touch Panel and Bezel Frame, White"

class sst_iosUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testMainFlow() {
        
        let app = XCUIApplication()
        
        // Guide
        while (app.scrollViews.count == 1) {
            app.scrollViews.firstMatch.swipeLeft()
            if app.buttons.matching(identifier: "icon start").element.exists {
                app.buttons["icon start"].tap()
                break
            }
        }
        
        // Home
        app.cells.element(boundBy: 5).tap()
        
        // ItemDetail
        app.buttons["Add to Cart"].tap()
        app.buttons.element(boundBy: 2).tap()
        
        // Cart
        app.buttons["Checkout"].firstMatch.tap()
        
        // Login
        if app.secureTextFields.count == 1 {
            let emailTextField = app.textFields["Email"]
            emailTextField.tap()
            if let email = emailTextField.value as? String {
                if email != "c@qq.com" {
                    let deleteKey = app.keys["delete"]
                    for _ in 0 ..< email.count {
                        deleteKey.tap()
                    }
                    emailTextField.typeText("c@qq.com")
                }
            }
            app.buttons["Next"].tap()
            let passwordSecureTextField = app.secureTextFields["Password"]
            passwordSecureTextField.tap()
            passwordSecureTextField.typeText("asdfed")
            app.buttons["Go"].tap()
        }
        
        // OrderConfirmation
        sleep(3)
        app.cells.element(boundBy: 1).tap()
        sleep(3)
        app.cells.firstMatch.tap()
        sleep(3)
        app.cells.element(boundBy: 3).tap()
        sleep(3)
        app.cells.firstMatch.tap()
        sleep(3)
        app.cells.element(boundBy: 5).tap()
        sleep(3)
        app.buttons["Continue"].tap()
        
        // PaymentOptions
        app.buttons["Place Order"].tap()
        
        // Paypal
        sleep(20)
        if app.webViews.count > 0 {
            app.navigationBars.firstMatch.buttons.firstMatch.tap()
            app.buttons["OK"].tap()
        }
        
        // PaymentResult
        sleep(3)
        app.buttons["View Order"].tap()
        
        // OrderDetail
        sleep(3)
        if app.buttons.count > 1 {
            XCTAssert(app.buttons.element(boundBy: app.buttons.count - 1).label == "Pay")
        }
    }
    
    func testHomeVC(){
            
    }
    
}
