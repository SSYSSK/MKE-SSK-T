//
//  SSTFavoriteVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTFavoriteVC: SSTBaseVC {

    @IBOutlet weak var myTableView: UITableView!
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    var itemIndClicked: Int?
    fileprivate var itemClicked: SSTItem?
    
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
        _ = self.myTableView.setUpHeaderRefresh(refreshHeaderView) {
            biz.favoriteData.fetchData()
        }
        
        biz.favoriteData.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        biz.favoriteData.fetchData()
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight)
        emptyView.setData(imgName: kNoFavoriteImgName, msg: kNoFavoriteTip, buttonTitle: kButtonTitleRefresh, buttonVisible: true)
        emptyView.buttonClick = {
            SSTProgressHUD.show(view: self.view)
            biz.favoriteData.fetchData()
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        for itm in biz.favoriteData.items {
            itm.promoCountdown = validInt64(itm.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
    }
    
    func resetViewAfterCancelWhenLoginByAntherAccount() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        biz.favoriteData.items.removeAll()
        myTableView.reloadData()
        SSTProgressHUD.show(view: self.view)
        biz.favoriteData.fetchData()
    }
    
    @objc func timerAlarm() {
        for ind in 0 ..< biz.favoriteData.items.count {
            if let item = biz.favoriteData.items.validObjectAtIndex(ind) as? SSTItem {
                item.minusOneToPromoCountdown()
            }
        }
        
        for cell in myTableView.visibleCells {
            let itemInd = validInt(myTableView.indexPath(for: cell)?.row)
            if itemInd < biz.favoriteData.items.count {
                let item = biz.favoriteData.items[itemInd]
                let timeLabel = (cell as! SSTFavoriteCell).countDownLabel
                timeLabel?.text = "\(item.promoCountdownText)"
            }
        }
    }
}

extension SSTFavoriteVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  biz.favoriteData.items.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 140.0
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueCell(SSTFavoriteCell.self) {
            if let item = biz.favoriteData.items.validObjectAtIndex(indexPath.row) as? SSTItem {
                cell.item = item
            }
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemClicked = biz.favoriteData.items[indexPath.row] as SSTItem
        itemIndClicked = indexPath.row
        self.performSegue(withIdentifier: SegueIdentifier.SegueToItemDetailVC.rawValue, sender: self)
    }
}

// MARK: -- Segue delegate
extension SSTFavoriteVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToItemDetailVC   = "ToItemDetailVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.SegueToItemDetailVC.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            let itemData = SSTItemData()
            itemData.items = biz.favoriteData.items
            destVC.itemData = itemData
            destVC.itemInd = itemIndClicked
        default:
            break
        }
    }
}

// MARK: -- SSTUIRefreshDelegate

extension SSTFavoriteVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if (data as? SSTFavoriteData) == nil {
            myTableView.endHeaderRefreshing(.failure, delay: 0.5)
        } else {
            myTableView.endHeaderRefreshing(.success, delay: 0.5)
            myTableView.reloadData()
        }
        emptyView.isHidden = biz.favoriteData.items.count > 0
    }
    
}
