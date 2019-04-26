//
//  SSTGuideVC.swift
//  sst-ios
//
//  Created by Amy on 16/7/12.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTGuideVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var showGuideFlag = false
        if validBool(getUserDefautsData(kGuideUpdatedKey))
            || validString(getUserDefautsData(kGuideAppPrevVersion)) != kAppVersion
            || Date().formatYYYYMM() != validString(getUserDefautsData(kGuideDateLastViewed)) { // guide have updated, or app have updated, or this month have not viewed
            showGuideFlag = true
        }
        
        if showGuideFlag && biz.guideData.guides.count > 0 {
            let guideView = loadNib("\(SSTGuideView.classForCoder())") as! SSTGuideView
            guideView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
            guideView.viewDisappeard = {
                self.showMainTC()
            }
            self.view.addSubview(guideView)
        } else {
            self.showMainTC()
        }
    }
    
    func showMainTC() {
        let mainTabbarC = UIStoryboard(name: kStoryBoard_Main, bundle: nil).instantiateViewController(withIdentifier: "\(SSTMainTC.classForCoder())") as! SSTMainTC
        UIApplication.shared.keyWindow?.rootViewController = mainTabbarC
    }
}
