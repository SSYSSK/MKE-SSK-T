//
//  SSTBaseTableViewController.swift
//  sst-mobile
//
//  Created by Amy on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit

class SSTBaseTVC: UITableViewController {
    
    var backButton: UIButton?
    var networkErrorTipView: SSTErrorTipView!
    
    // 收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if networkErrorTipView == nil {
            networkErrorTipView = loadNib("\(SSTErrorTipView.classForCoder())") as? SSTErrorTipView
            networkErrorTipView?.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: 39)
            networkErrorTipView?.message = kInternetConnectionNotAvialable
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if validInt(self.navigationController?.viewControllers.count) > 1 {
//            addLeftItemButton()
//        }
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.tintColor = UIColor.white.withAlphaComponent(0.7)
        
        TaskUtil.delayExecuting(1) {
            self.showErrorTipView()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(networkChanged(_:)), name: NSNotification.Name(rawValue: kNetworkStatusNofication), object: nil)
    }
    
    func showErrorTipView() {
        if biz.ntwkAccess.networkIsAvailable == false {
            self.view.addSubview(networkErrorTipView)
        } else {
            self.networkErrorTipView.removeFromSuperview()
        }
    }
    
    func fetchData() {}
    
    @objc func networkChanged(_ notification: Notification) {
        showErrorTipView()
        fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        backButton?.removeFromSuperview()
        SSTProgressHUD.dismiss(view: self.view)
    }
    
    func addLeftItemButton() -> Void {
        
        backButton = UIButton(type: UIButtonType.custom)
        backButton?.frame = kBackButtonRect
        backButton?.addTarget(self, action: #selector(clickedBackBarButton), for: UIControlEvents.touchUpInside)
        
        backButton?.setImage(UIImage(named:kIconBackImgName), for: UIControlState())
        backButton?.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 10)
        
        if let tmpButton = backButton {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: tmpButton)
        }
    }
    
    @objc func clickedBackBarButton() -> Void {
        _ = self.navigationController?.popViewController(animated: true)
    }
}

