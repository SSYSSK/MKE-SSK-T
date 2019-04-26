//
//  SSTBrowseHistoryVC.swift
//  sst-ios
//
//  Created by Amy on 2016/10/18.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import PullToRefreshKit

class SSTRecentlyViewedVC: SSTBaseVC {
    
    @IBOutlet weak var myTableView: UITableView!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    fileprivate var pageNum = 1 //默认从1开始
    
    fileprivate var itemIndClicked: Int?
    var browseData = SSTBrowseHistory()
    
    fileprivate var itemClicked: SSTItem?
    
    fileprivate var isDeleteButtonEnable = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = myTableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.upPullLoadData()
        }
        _ = myTableView.setUpFooterRefresh { [weak self] in
            self?.downPullLoadData()
            }.SetUp { (footer) in
                setRefreshFooter(footer)
        }
        
        browseData.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        browseData.fetchData(pageNum)
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight)
        emptyView.setData(imgName: kNoRecentlyViewedImgName, msg: kNoRecentlyViewedTip, buttonTitle: kButtonTitleRefresh, buttonVisible: true)
        emptyView.buttonClick = {
            SSTProgressHUD.show(view: self.view)
            self.browseData.fetchData(self.pageNum)
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        for itm in browseData.items {
            itm.promoCountdown = validInt64(itm.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        browseData.items.removeAll()
        myTableView.reloadData()
        SSTProgressHUD.show(view: self.view)
        browseData.fetchData()
    }

    func upPullLoadData() {
        browseData.fetchData()
    }
    
    func downPullLoadData() {
        browseData.fetchDataForNextPage()
    }
    
    @IBAction func clickedEmptyAction(_ sender: AnyObject) {
        SSTProgressHUD.show(view: self.view)
        browseData.removeAllHistory({ (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                self.browseData.items.removeAll()
                self.refreshView()
            }
        })
    }
    
    @objc func timerAlarm() {
        for ind in 0 ..< browseData.items.count {
            if let item = browseData.items.validObjectAtIndex(ind) as? SSTItem {
                item.minusOneToPromoCountdown()
            }
        }
        
        for cell in myTableView.visibleCells {
            let tCell = cell as! SSTBrowseHistoryCell
            tCell.countDownLabel.text = tCell.item.promoCountdownText
        }
    }
    
    func refreshView() {
        if browseData.groups.count > 0 {
            emptyView.isHidden = true
            myTableView.reloadData()
        } else {
            emptyView.isHidden = false
        }
        myTableView.isHidden = !emptyView.isHidden
        myTableView.reloadData()
    }
}

extension SSTRecentlyViewedVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return browseData.groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validInt((browseData.groups.validObjectAtIndex(section) as? SSTGroup)?.items.count)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 35))
        let titleLabel = UILabel(frame: CGRect(x: 15, y: 10, width: kScreenWidth, height: 20))
        titleLabel.text = (browseData.groups.validObjectAtIndex(section) as? SSTGroup)?.name
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        outerView.addSubview(titleLabel)
        return outerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTBrowseHistoryCell.classForCoder())") as? SSTBrowseHistoryCell {
            if let item = (browseData.groups.validObjectAtIndex(indexPath.section) as? SSTGroup)?.items.validObjectAtIndex(indexPath.row) as? SSTHistoryItem {
                cell.item = item
            }
            cell.deleteHistoryBlock = { [weak self] (item) in
                if !validBool(self?.isDeleteButtonEnable) {
                    SSTToastView.showError(kOperationTooFastTip)
                    return
                }
                SSTProgressHUD.show(view: self?.view)
                self?.isDeleteButtonEnable = false
                self?.browseData.removeFromBrowseHistory([item], callback: { (data, error) in
                    self?.isDeleteButtonEnable = true
                    SSTProgressHUD.dismiss(view: self?.view)
                    if error == nil {
                        self?.refreshView()
                    } else {
                        SSTToastView.showError(kErrorTip)
                    }
                })
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let group = browseData.groups.validObjectAtIndex(indexPath.section) as? SSTGroup {
            if let item = group.items.validObjectAtIndex(indexPath.row) as? SSTHistoryItem {
                itemClicked = item
                itemIndClicked = browseData.getItemIndex(item)
                self.performSegue(withIdentifier: SegueIdentifier.SegueToItemDetailVC.rawValue, sender: self)
            }
        }
    }
}

// MARK: -- Segue delegate
extension SSTRecentlyViewedVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToItemDetailVC = "ToItemDetailVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.SegueToItemDetailVC.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            destVC.item = itemClicked
            
            let itemData = SSTItemData()
            itemData.items = browseData.items
            destVC.itemData = itemData
            destVC.itemInd = itemIndClicked
            
        default:
            break
        }
    }
}

extension SSTRecentlyViewedVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        
        if (data as? SSTBrowseHistory) == nil {
            myTableView.endHeaderRefreshing(.failure, delay: 0.5)
        } else {
            myTableView.endHeaderRefreshing(.success, delay: 0.5)
            if browseData.items.count >= browseData.pageNum * kPageSize {
                myTableView.endFooterRefreshing()
            } else {
                myTableView.endFooterRefreshingWithNoMoreData()
            }
            
            browseData = data as! SSTBrowseHistory
            refreshView()
        }
    }
    
}
