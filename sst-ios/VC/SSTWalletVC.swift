//
//  SSTWalletVCViewController.swift
//  sst-ios
//
//  Created by Amy on 2017/3/20.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import PullToRefreshKit

class SSTWalletVC: SSTBaseVC {

    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var totalAmount: UILabel!
    @IBOutlet weak var headViewHeightConstraint: NSLayoutConstraint!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    var walletInfo = SSTWalletData()
    var pageNum = 1
    var clickedOrderId = ""
    let kHeadViewHeight: CGFloat = 120
    
    var navToNextVC = false
    var isFirstAppear = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        headViewHeightConstraint.constant = kScreenNavigationHeight + 60
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = myTableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.upPullLoadData()
        }
        _ = myTableView.setUpFooterRefresh { [weak self] in
            self?.downPullLoadData()
            }.SetUp { (footer) in
                setRefreshFooter(footer)
        }
        
        walletInfo.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        self.getWalletInfo()
        
        emptyView.frame = CGRect(x: 0, y: kHeadViewHeight, width: kScreenWidth, height: kScreenHeight - kHeadViewHeight - kScreenTabbarHeight)
        emptyView.setData(imgName: kNoWalletRecordImgName, msg: kNoWalletRecordTip, buttonTitle: kButtonTitleRefresh, buttonVisible: true)
        emptyView.buttonClick = {
            SSTProgressHUD.show(view: self.view)
            self.getWalletInfo()
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil  // hide the top Navigation bar and still have the swipe
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let isPrevVCEqualMoreVC = validBool(self.navigationController?.childViewControllers.validObjectAtLoopIndex(-2)?.isKind(of: SSTMoreVC.self))
        if isFirstAppear && isPrevVCEqualMoreVC || !isFirstAppear && !navToNextVC {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        navToNextVC = false
        isFirstAppear = false
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if navToNextVC || validBool(self.navigationController?.childViewControllers.last?.isKind(of: SSTBasePayVC.classForCoder())) {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            if validBool(self.navigationController?.childViewControllers.last?.isKind(of: SSTMoreVC.self)) {
                //
            } else {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
        super.viewWillDisappear(animated)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.upPullLoadData()
    }

    func upPullLoadData() {
        pageNum = 1
        SSTProgressHUD.show(view: self.view)
        self.getWalletInfo()
    }
    
    func downPullLoadData() {
        self.getWalletInfo()
    }

    private func getWalletInfo() {
        walletInfo.getWalletDetailInfo(pageNum: pageNum)
    }
    
    @IBAction func clickedBackEvent(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}

// Mark: -- UITableViewDelegate, UITableViewDataSource

extension SSTWalletVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if walletInfo.items.count > 0 {
            return walletInfo.items.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = loadNib("\(SSTSectionHeadCell.classForCoder())") as! SSTSectionHeadCell
            cell.icon.image = UIImage(named: kWalletRecordImgName)
            cell.title.text = kWalletTransactionTitle
            return cell
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTWalletInfoCell.classForCoder())", for: indexPath) as? SSTWalletInfoCell {
                if let wallet = walletInfo.items.validObjectAtIndex(indexPath.row - 1) as? SSTWallet {
                    cell.walletInfo = wallet
                }
                cell.clickedOrderBlock = { [weak self](orderId) in
                    self?.clickedOrderId = orderId
                    self?.performSegueWithIdentifier(.SegueToOrderDetailVC, sender:nil)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}

extension SSTWalletVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        
        if data != nil {
            walletInfo = data as! SSTWalletData
            if walletInfo.items.count == 0 {
                emptyView.isHidden = false
            } else {
                emptyView.isHidden = true
            }
            self.myTableView.isHidden = !emptyView.isHidden
            
            if validDouble(walletInfo.totalAmount) < 0 {
                totalAmount.text = "- \((validDouble(walletInfo.totalAmount) * -1).formatC())"
            } else {
                totalAmount.text = walletInfo.totalAmount?.formatC()
            }
            
            if pageNum == 1 {
                myTableView.endHeaderRefreshing(.success, delay: 0.5)
                myTableView.endFooterRefreshing()
            } else{
                if walletInfo.items.count >= pageNum * kPageSize {
                    myTableView.endFooterRefreshing()
                } else if walletInfo.items.count > 0 {
                    myTableView.endFooterRefreshingWithNoMoreData()
                }
            }
            pageNum += 1
            self.myTableView.reloadData()
        } else {
            myTableView.endFooterRefreshingWithNoMoreData()
        }
    }
}

// MARK: -- Segue delegate
extension SSTWalletVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToOrderDetailVC = "ToOrderDetailVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navToNextVC = true
        switch segueIdentifierForSegue(segue) {
        case .SegueToOrderDetailVC:
            let destVC = segue.destination as! SSTOrderDetailVC
            destVC.orderId = clickedOrderId
        
        }
    }
}
