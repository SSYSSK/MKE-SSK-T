//
//  AppDelegate.swift
//  sst-ios
//
//  Created by Liang Zhang on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let biz = BizRequestCenter()
let gGlobalConfigs = GlobalConfigs()

var appDelegate: AppDelegate!

var gDeviceTokenString = ""
var gLatestApplicatonDidBecomeActiveDateYYYYMMDD: String = ""
var gFromLastEnterBackgroundToEnterForgroundSeconds: Int64 = 0

var gPaypalClientId: String = ""

weak var gLoginVC: SSTLoginAndRegisterVC?
weak var gMainTC: UITabBarController?

var gNotificationStatus: NotificationEnableStatus {
    get {
        if UIApplication.shared.currentUserNotificationSettings?.types == UIUserNotificationType() {
            return NotificationEnableStatus.Off
        } else {
            return NotificationEnableStatus.On
        }
    }
}

let kErrorFileName = "error.data"
let kErrorFileTime = "error.time"
let kNotificationInfo = "info"
let kNotificationInfoType = "type"
let kNotificationInfoValue = "detail"

let kApplicationWillEnterForeground = NSNotification.Name(rawValue: "kApplicationWillEnterForeground")
let kApplicationDidBecomeActive = NSNotification.Name(rawValue: "kApplicationDidBecomeActive")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var aTask: AsynTask?
    var aTaskType: Int?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        appDelegate = self
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        let userDefault = UserDefaults.standard
        gDeviceTokenString = validString(userDefault.value(forKey: kDeviceToken))
        
        setupKeyBoardMananger()
        
        #if DEV
            printExceptions()
        #endif
        
        self.window?.backgroundColor = UIColor.white
        
        NSSetUncaughtExceptionHandler { exception in
            var exceptions = [Dictionary<String,Any>]()
            if let tExps = FileOP.unarchive(kErrorFileName) as? [Dictionary<String,Any>] {
                exceptions = tExps
            }
            if exceptions.count > 5 {
                exceptions.removeFirst()
            }
            let dict: [String : Any] = [
                "date":Date(),
                "name":exception.name,
                "reason":validString(exception.reason),
                "callStackSymbols":exception.callStackSymbols
            ]
            exceptions.append(dict)
            FileOP.archive(kErrorFileName, object: exceptions)
        }
        
        // Check if launched from notification
        if let userInfo = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            handleActionAfterReceiveNotification(userInfo)
        }
        
        // add short items for app
        
        let searchIcon = UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.search)
        let searchItem = UIApplicationShortcutItem(type: "search", localizedTitle: "Search", localizedSubtitle: "", icon: searchIcon, userInfo: nil)
        
        let cartIcon = UIApplicationShortcutIcon(templateImageName: "tab_cart_normal")
        let cartItem = UIApplicationShortcutItem(type: "cart", localizedTitle: "Cart", localizedSubtitle: "", icon: cartIcon, userInfo: nil)
        
        let orderIcon = UIApplicationShortcutIcon(type: UIApplicationShortcutIconType.compose)
        let orderItem = UIApplicationShortcutItem(type: "order", localizedTitle: "Order", localizedSubtitle: "", icon: orderIcon, userInfo: nil)
        
        application.shortcutItems = [searchItem,cartItem,orderItem]
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        switch shortcutItem.type {
        case "search":
            gMainTC?.selectedIndex = TabIndexType.home.rawValue
            if let nc = gMainTC?.selectedViewController as? UINavigationController {
                nc.popToRootViewController(animated: false)
                if let homeVC = nc.childViewControllers.first as? SSTHomeVC {
                    homeVC.clickedSearchBarButton(nil)
                }
            }
        case "cart":
            gMainTC?.selectedIndex = TabIndexType.cart.rawValue
            if let nc = gMainTC?.selectedViewController as? UINavigationController {
                nc.popToRootViewController(animated: false)
            }
        case "order":
            gMainTC?.selectedIndex = TabIndexType.more.rawValue
            if let nc = gMainTC?.selectedViewController as? UINavigationController {
                nc.popToRootViewController(animated: false)
                if let moreVC = nc.childViewControllers.first as? SSTMoreVC {
                    moreVC.performSegue(withIdentifier: SSTMoreVC.SegueIdentifier.SegueToOrderVC.rawValue, sender: nil)
                }
            }
        default:
            break
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserDefaults.standard.set(Date(), forKey: "DidEnterBackgroundTime")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        NotificationCenter.default.post(name: kApplicationWillEnterForeground, object: nil, userInfo: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        biz.user.activeSeconds = 0
        
        // need execute before post notification
        gLatestApplicatonDidBecomeActiveDateYYYYMMDD = validString(UserDefaults.standard.value(forKey: "LatestApplicatonDidBecomeActiveDate"))
        if gLatestApplicatonDidBecomeActiveDateYYYYMMDD != Date().formatYYYYMMDD() {
            UserDefaults.standard.set(Date().formatYYYYMMDD(), forKey: "LatestApplicatonDidBecomeActiveDate")
        }
        gFromLastEnterBackgroundToEnterForgroundSeconds = -validInt64((UserDefaults.standard.value(forKey: "DidEnterBackgroundTime") as? Date)?.timeIntervalSince(Date())) * kItemPromoCountdownUnit
        
        NotificationCenter.default.post(name: kApplicationDidBecomeActive, object: nil, userInfo: nil)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
    //        if notificationSettings.types != .None {
    //            application.registerForRemoteNotifications()
    //        }
    //    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        printDebug("Device Token:", tokenString)
        gDeviceTokenString = tokenString
        let userDefault = UserDefaults.standard
        userDefault.set(tokenString, forKey: kDeviceToken)
        userDefault.synchronize()
        
        if gDeviceTokenString.isNotEmpty {
            biz.uploadPushDeviceToken(gDeviceTokenString) { (data, error) in
                if error != nil {
                    #if DEV
                    SSTToastView.showError("Fail from API for uploading Device Token: \(validString(error))")
                    #endif
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        #if DEV
        SSTToastView.showError("Fail to register notification: \(error)")
        #endif
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        handleActionAfterReceiveNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background {
            handleActionAfterReceiveNotification(userInfo)
        } else if application.applicationState == UIApplicationState.active  {
            let info = validDictionary(userInfo)
            if aTask != nil && aTaskType == validInt(info[kNotificationInfoType]) {
                TaskUtil.cancel(aTask)
            }
            aTask = TaskUtil.delayExecuting(0.5, block: {
                let msg = validString(validDictionary(validDictionary(userInfo)["aps"])["alert"])
                
                let mAC = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                let ignoreAction = UIAlertAction(title: "Ignore", style: .default, handler: nil)
                let detailAction = UIAlertAction(title: "Detail", style: .default, handler: { action in
                    self.handleActionAfterReceiveNotification(userInfo)
                })
                mAC.addAction(ignoreAction)
                mAC.addAction(detailAction)
                
                gMainTC?.present(mAC, animated: true, completion: nil)
            })
            aTaskType = validInt(info[kNotificationInfoType])
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        handleActionAfterReceiveNotification(userInfo)
    }
    
    // MARK: -- called function for AppDelegate
    
    /**
     配置键盘管理
     */
    fileprivate func setupKeyBoardMananger() {
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = false     // set the toolbar hidden above the keyboard
    }
    
    func printExceptions() {
        if let tExps = FileOP.unarchive(kErrorFileName) {
            for exp in validArray(tExps) {
                if let dict = exp as? Dictionary<String,Any> {
                    printDebug("Exception Info －－－\n date:\(validString(dict["date"]))\n name:\(validString(dict["name"]))\n reason:\(validString(dict["reason"]))\n callStackSymbols:\(validString(dict["callStackSymbols"]))\n --- end.")
                }
            }
        }
    }
    
    func handleActionAfterReceiveNotification(_ userInfo: [AnyHashable: Any]) {
        let info = validDictionary(userInfo)
        handleActionAfterReciveMsg(type: validInt(info[kNotificationInfoType]), value: validString(info[kNotificationInfoValue]))
    }
    
    func handleActionAfterReciveMsg(type: Int, value: String) {
        if let tabbarController = window?.rootViewController as? UITabBarController {
            switch type {
            case NotificationInfoType.search.rawValue:
                tabbarController.selectedIndex = TabIndexType.home.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let homeVC = navigationController.childViewControllers.first as? SSTHomeVC {
                        homeVC.searchKey = value
                        homeVC.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toSearchResult.rawValue, sender: nil)
                    }
                }
            case NotificationInfoType.deals.rawValue:
                tabbarController.selectedIndex = TabIndexType.deal.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                }
            case NotificationInfoType.productDetail.rawValue:
                tabbarController.selectedIndex = TabIndexType.home.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let homeVC = navigationController.childViewControllers.first as? SSTHomeVC {
                        SSTItem.fetchItemById(value) { data, error in
                            if error == nil {
                                homeVC.itemClicked = data as? SSTItem
                                homeVC.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toItemDetail.rawValue, sender: nil)
                            }
                        }
                    }
                }
            case NotificationInfoType.web.rawValue:
                tabbarController.selectedIndex = TabIndexType.home.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let homeVC = navigationController.childViewControllers.first as? SSTHomeVC {
                        homeVC.webUrl = value
                        homeVC.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toWeb.rawValue, sender: nil)
                    }
                }
            case NotificationInfoType.orderDetail.rawValue:
                tabbarController.selectedIndex = TabIndexType.home.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let homeVC = navigationController.childViewControllers.first as? SSTHomeVC {
                        homeVC.orderId = value
                        homeVC.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toOrderDetailVC.rawValue, sender: nil)
                    }
                }
            case NotificationInfoType.wallet.rawValue:
                tabbarController.selectedIndex = TabIndexType.more.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let moreVC = navigationController.childViewControllers.first as? SSTMoreVC {
                        moreVC.performSegue(withIdentifier: SSTMoreVC.SegueIdentifier.SegueToWalletVC.rawValue, sender: nil)
                    }
                }
            case NotificationInfoType.justTips.rawValue:
                printDebug("--")
            case NotificationInfoType.message.rawValue:
                tabbarController.selectedIndex = TabIndexType.home.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let homeVC = navigationController.childViewControllers.first as? SSTHomeVC {
                        homeVC.msgId = value
                        homeVC.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toWeb.rawValue, sender: nil)
                    }
                }
            case NotificationInfoType.contact.rawValue:
                tabbarController.selectedIndex = TabIndexType.more.rawValue
                if let nc = tabbarController.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                    if let moreVC = navigationController.childViewControllers.first as? SSTMoreVC {
                        moreVC.performSegue(withIdentifier: SSTMoreVC.SegueIdentifier.SegueToContactSST.rawValue, sender: nil)
                    }
                }
            default:
                break
            }
        }
    }
    
}
