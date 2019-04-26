//
//  SSTSettingVC.swift
//  sst-ios
//
//  Created by Amy on 16/8/22.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
//import Async

class SSTSettingVC: SSTBaseVC {

//    var settingsInfo = SSTSetting()
    
    var logoutBlock:((_ isLogout:Bool) ->Void)?
    
    @IBOutlet weak var myTableView: UITableView!
    
    var version = String()
    var caches = String()
    var itemClicked = SSTSetting()
    var subsTitle = String()
    
    fileprivate var logoCell         = "SSTSettingLogoCell"
    fileprivate var notificationCell = "SSTSettingNotificationCell"
    fileprivate var cacheCell        = "SSTSettingCacheCell"
    fileprivate var servicesCell     = "SSTSettingServiceCell"
    fileprivate var signoutCell      = "SSTSettingSignoutCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        settingsInfo.delegate = self
//        settingsInfo.fetchData()
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        version = kAppVersion
        caches = FileOP.folderSize(path: kCachePath).formatCWithoutCurrency() + "M"

        NotificationCenter.default.addObserver(self, selector:#selector(refreshNotificationStatusText) , name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @objc func refreshNotificationStatusText() {
        self.myTableView.reloadSections(IndexSet(integer: 0), with: .none)
    }
    
    //清除缓存
    fileprivate func clearCacheEvent() {
        weak var tmpSelf = self
        FileOP.cleanFolder(path: kCachePath) { () -> () in
            tmpSelf?.caches = "0.00M"
            SSTToastView.showSucceed(kMoreClearCacheTip)
            self.myTableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
    }
    
    // MARK: -- 退出登录
    @objc fileprivate func signOutEvent() {
        SSTProgressHUD.show(view: self.view)
        biz.user.logout({ (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                (gMainTC?.selectedViewController?.childViewControllers.first as? SSTMoreVC)?.refreshProfileCell()
                _ = self.navigationController?.popViewController(animated: true)
                biz.cart.fetchData()
                self.logoutBlock?(true)
            } else {
                SSTToastView.showError(validString(error.debugDescription))
            }
        }) { (errorCode) in
            _ = self.navigationController?.popViewController(animated: true)
            return true
        }
    }
}

extension SSTSettingVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (biz.user.isLogined ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let backgroundView:UIView = UIView()
        backgroundView.backgroundColor = UIColor.groupTableViewBackground
        return backgroundView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        if section == 0 {
            return 4
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 180
            }
            return 44
        default:
            return 44
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "\(logoCell)", for: indexPath)
                (cell?.viewWithTag(1001) as? UILabel)?.text = "V\(kAppVersion)"
            } else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCell(withIdentifier: "Security", for: indexPath)
            } else if indexPath.row == 2 {
                cell = tableView.dequeueReusableCell(withIdentifier: "\(notificationCell)", for: indexPath)
                if let switchOff = cell?.viewWithTag(100) as? UILabel {
                    switchOff.text = gNotificationStatus.rawValue
                }
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: "\(cacheCell)", for: indexPath)
                if let caches = cell?.viewWithTag(200) as? UILabel {
                    caches.text = self.caches
                }
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "\(signoutCell)", for: indexPath)
            (cell?.viewWithTag(1001) as? UIButton)?.addTarget(self, action: #selector(signOutEvent), for: .touchUpInside)
        }
        
        if let tCell = cell {
            return tCell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return
            } else if indexPath.row == 1 {
                if biz.user.isLogined {
                    self.performSegue(withIdentifier: SegueIdentifier.toSecurity.rawValue, sender: self)
                } else {
                    presentLoginVC({ (data, error) in
                        if biz.user.isLogined {
                            self.performSegue(withIdentifier: SegueIdentifier.toSecurity.rawValue, sender: self)
                        }
                    })
                }
            } else if indexPath.row == 2 { // notification to switch
                if let settingUrl = NSURL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(settingUrl as URL) {
                        UIApplication.shared.openURL(settingUrl as URL)
                    }
                }
            } else { // clear cache
                clearCacheEvent()
            }
        default:
            break
        }
    }
}

extension SSTSettingVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case toWeb      = "toWeb"
        case toSecurity = "toSecurity"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .toWeb:
            let destVC = segue.destination as! SSTWebVC
            destVC.webTitle = validString(itemClicked.title)
            destVC.webUrl = validString(itemClicked.url)
        case .toSecurity:
            break
        }
    }

}

extension SSTSettingVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        if data != nil {
            self.myTableView.reloadData()
        }
    }
}
