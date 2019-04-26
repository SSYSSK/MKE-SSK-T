//
//  SSTDealsVC.swift
//  sst-ios
//
//  Created by Amy on 16/8/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kPromoMsgHeight: CGFloat = 35
let kDealsVCCollectionCellSpacing: CGFloat = 1
let dealsCellIdentify = "SSTDealsCell"

class SSTDealsVC: SSTBaseVC {
    
    @IBOutlet weak var promoMsgView: UIView!
    @IBOutlet weak var promoMsgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    fileprivate var dealsData = SSTDealsData()
    
    fileprivate var itemClicked: SSTItem?
    fileprivate var lastContentOffsetY: CGFloat = 0
    
    var itemIndClicked: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName:"\(SSTDealsCell.classForCoder())", bundle: nil), forCellWithReuseIdentifier: dealsCellIdentify)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        lastContentOffsetY = collectionView.contentOffset.y
    
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        if kIsIphoneX {
            collectionView.frame = CGRect(x: 0, y: kScreenNavigationHeight + kPromoMsgHeight, width: kScreenWidth, height: kScreenViewHeight - kPromoMsgHeight)
        } else {
            collectionView.frame = CGRect(x: 0, y: kPromoMsgHeight, width: kScreenWidth, height: kScreenHeight - kPromoMsgHeight)
        }
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 70))
        _ = self.collectionView.setUpHeaderRefresh(refreshHeaderView) {
            self.dealsData.fetchData()
        }
        
        dealsData.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        dealsData.fetchData()
        
        if biz.dealMessage.msgs.count > 0 {
            let loopView = loadNib("\(SSTPromoMsgView.classForCoder())") as! SSTPromoMsgView
            loopView.frame.size = CGSize(width: kScreenWidth, height: kPromoMsgHeight)
            loopView.setDealMessage()
            for vw in self.promoMsgView.subviews {
                vw.removeFromSuperview()
            }
            self.promoMsgView.addSubview(loopView)
            self.promoMsgView.isHidden = false
            self.promoMsgViewHeight.constant = kPromoMsgHeight
            collectionView.sizeToFit()
        } else {
            self.promoMsgView.isHidden = true
            self.promoMsgViewHeight.constant = 0
        }
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight + promoMsgViewHeight.constant, width: kScreenWidth, height: kScreenViewHeight - promoMsgViewHeight.constant)
        emptyView.setData(imgName: kIcon_badConnected, msg: kNoDataTip, buttonTitle: kButtonTitleTryAgain, buttonVisible: true)
        emptyView.buttonClick = {
            SSTProgressHUD.show(view: self.view)
            self.dealsData.fetchData()
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        
        self.view.bringSubview(toFront: self.promoMsgView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func viewRefreshWhenCartUpdated() {
        if collectionView != nil {
            for cell in collectionView.visibleCells {
                (cell as? SSTDealsCell)?.itemV.setQtyTFAndButtons()
            }
        }
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        for group in dealsData.groups {
            for itm in group.items {
                (itm as? SSTItem)?.promoCountdown = validInt64((itm as? SSTItem)?.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
            }
        }
        
        dealsData.fetchData()
    }

    @objc func timerAlarm() {
        for group in dealsData.groups {
            for itm in group.items {
                (itm as? SSTItem)?.minusOneToPromoCountdown()
            }
        }
        for cell in collectionView.visibleCells {
            (cell as? SSTDealsCell)?.itemV.refreshCountdown()
        }
    }
}

extension SSTDealsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dealsData.groups.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dealsData.groups[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: dealsCellIdentify, for: indexPath) as! SSTDealsCell
        
        if let group = self.dealsData.groups.validObjectAtIndex(indexPath.section) as? SSTGroup {
            if let it = group.items[indexPath.row] as? SSTItem {
                cell.item = it
            }
        }
        cell.indexPath = indexPath
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells {
            if cell.isKind(of: SSTDealsCell.classForCoder()) {
                (cell as! SSTDealsCell).itemV.qtyTF.resignFirstResponder()
            }
        }
        let group = self.dealsData.groups[indexPath.section]
        itemClicked = group.items[indexPath.row] as? SSTItem
        itemIndClicked = indexPath.row
        self.performSegue(withIdentifier: SegueIdentifier.SegueToItemDetail.rawValue, sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item % 2 != 0 {
            return CGSize(width: (kScreenWidth - 2) / 2 + 1, height: kSearchResultViewGridHeight)
        } else {
            return CGSize(width: (kScreenWidth - 2) / 2 , height: kSearchResultViewGridHeight)
        }
    }

}

// MARK: -- UIScrollViewDelegate

extension SSTDealsVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            let itmV = (cell as! SSTDealsCell).itemV
            if itmV.qtyTF.isFirstResponder {
                itmV.qtyTF.resignFirstResponder()
            }
        }
    }
}

//MARK:-- Segue delegate

extension SSTDealsVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToItemDetail   = "ToItemDetailVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.SegueToItemDetail.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            
            let itemData = SSTItemData()
            var items = [SSTItem]()
            for group in dealsData.groups {
                for item in group.items {
                    if let it = item as? SSTItem {
                        items.append(it)
                    }
                }
            }
            itemData.items = items
            destVC.itemData = itemData
            
            destVC.itemInd = itemIndClicked
        default:
            break
        }
    }
}

extension SSTDealsVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if (data as? SSTDealsData) == nil {
            collectionView.endHeaderRefreshing(.failure, delay: 0.5)
        } else {
            collectionView.endHeaderRefreshing(.success, delay: 0.5)
            if data != nil {
                dealsData = data as! SSTDealsData
                collectionView.reloadData()
            }
        }
        emptyView.isHidden = dealsData.groups.count <= 0 ? false : true
    }
}

