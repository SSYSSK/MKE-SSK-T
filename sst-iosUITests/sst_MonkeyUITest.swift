//
//  sst_MonkeyUITest.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/21/16.
//  Copyright © 2016 SST. All rights reserved.
//

import XCTest

class sst_MonkeyUITest: XCTestCase {
    
    var testCnt = 0
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    override func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: UInt, expected: Bool) {
        print("\(description) \(self.testCnt)")
    }
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func fRandom(_ upperBound: UInt32) -> UInt32 {
        return arc4random_uniform(upperBound)
    }
    
    func testMonkey() {
        let app = XCUIApplication()
        
        for _ in 0 ..< 1000000 {
            
            // Login or Paypal
            if app.secureTextFields.count == 1 {
                var isLoginV = false
                for ind in 0 ..< app.buttons.count {
                    sleep(1)
                    if app.buttons.element(boundBy: ind).label == "Sign In" {  // Login
                        isLoginV = true
                        break
                    }
                }
                if isLoginV {
                    let emailTextField = app.textFields["Email"]
                    emailTextField.tap()
                    if let email = emailTextField.value as? String {
                        if email != "lzhang@sstparts.com" {
                            let deleteKey = app.keys["delete"]
                            for _ in 0 ..< email.count {
                                deleteKey.tap()
                            }
                            emailTextField.typeText("lzhang@sstparts.com")
                        }
                    }
                    app.buttons["Next"].tap()
                    let passwordSecureTextField = app.secureTextFields["Password"]
                    passwordSecureTextField.tap()
                    passwordSecureTextField.typeText("asdfed")
                    app.buttons["Go"].tap()
                } else {
                    // Paypal
                }
            }
            
            var isValidAction = false
            for _ in 0 ..< 999 {
                sleep(2)
                switch fRandom(9) {
                case 1,2,3:
                    if app.cells.count > 0 {
                        let ind = UInt(fRandom(UInt32(app.buttons.count)))
                        let cell = app.cells.element(boundBy: ind)
                        if cell.exists && ind < app.cells.count {
                            cell.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                            isValidAction = true
                        }
                    }
                case 4:
                    if app.scrollViews.count > 0 {
                        let scrollView = app.scrollViews.element(boundBy: UInt(fRandom(UInt32(app.scrollViews.count))))
                        if scrollView.exists && scrollView.isHittable {
                            switch fRandom(4) {
                            case 0:
                                scrollView.swipeDown()
                            case 1:
                                scrollView.swipeUp()
                            case 2:
                                scrollView.swipeLeft()
                            default:
                                scrollView.swipeRight()
                            }
                            isValidAction = true
                        }
                    }
                default:
                    if app.buttons.count > 0 {
                        let ind = UInt(fRandom(UInt32(app.buttons.count)))
                        let button = app.buttons.element(boundBy: ind)
                        if button.isHittable && ind < app.buttons.count {
                            button.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
                            isValidAction = true
                        }
                    }
                }
                if isValidAction {
                    break
                }
            }
            
            testCnt += 1
        }
        
        print("Complete Monkey Test. \(testCnt)")
    }
    
    func randomCGFloat(_ upperBound: CGFloat) -> CGFloat {
        return CGFloat(arc4random_uniform(UInt32(upperBound)))
    }
    
    func testMonkeyWithCoordinate() {
        let app = XCUIApplication()
        
        for _ in 0 ..< 1000000 {
            app.coordinate(withNormalizedOffset: CGVector(dx: Double(fRandom(10))/10, dy: Double(fRandom(10))/10)).tap()
            
            testCnt += 1
        }
    }
    
    func testMonkey2() {
        let application = XCUIApplication()
        
        // Workaround for bug in Xcode 7.3. Snapshots are not properly updated
        // when you initially call app.frame, resulting in a zero-sized rect.
        // Doing a random query seems to update everything properly.
        // TODO: Remove this when the Xcode bug is fixed!
        _ = application.descendants(matching: .any).element(boundBy: 0).frame
        
        // Initialise the monkey tester with the current device
        // frame. Giving an explicit seed will make it generate
        // the same sequence of events on each run, and leaving it
        // out will generate a new sequence on each run.
        let monkey = Monkey(frame: application.frame)
        //let monkey = Monkey(seed: 123, frame: application.frame)
        
        // Add actions for the monkey to perform. We just use a
        // default set of actions for this, which is usually enough.
        // Use either one of these but maybe not both.
        // XCTest private actions seem to work better at the moment.
        // UIAutomation actions seem to work only on the simulator.
        monkey.addDefaultXCTestPrivateActions()
        //monkey.addDefaultUIAutomationActions()
        
        // Occasionally, use the regular XCTest functionality
        // to check if an alert is shown, and click a random
        // button on it.
        monkey.addXCTestTapAlertAction(interval: 100, application: application)
        
        // Run the monkey test indefinitely.
        monkey.monkeyAround()
    }
    
}
