//
//  SSTProductDetailVC.swift
//  sst-ios
//
//  Created by Amy on 16/4/28.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit
import PullToRefreshKit

let kPromoMsgViewHeight: CGFloat = 35
let kSSTItemDetailsInfoCell: String = "SSTItemDetailsInfoCell"

class SSTItemDetailVC: SSTBaseVC, UIScrollViewDelegate {
    
    var itemId: String?
    var item: SSTItem?
    
    var itemData: SSTItemData?
    var itemInd: Int?
    
    @IBOutlet weak var promoMsgView: UIView!
    @IBOutlet weak var promoMsgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var soldButton: UIButton!
    @IBOutlet weak var cartQtyLabel: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    @IBOutlet weak var addToCartButton: UIButton!
    
    @IBOutlet weak var emptyViewMessage: UILabel!
    @IBOutlet weak var emptyView: UIView!
    
    var scrollViewHeight: CGFloat {
        get {
            if biz.dealMessage.msgs.count > 0 {
                return kScreenViewHeight - 35
            } else {
                return kScreenViewHeight
            }
        }
    }
    
    fileprivate var sKUViewCell: SSTSKUViewCell!
    fileprivate var dailyDealsCell: SSTDailyDealsCell!
    fileprivate var discountCell: SSTProductDiscountCell!

    fileprivate let ItemSlideCell     = "SSTItemSlideCell"
    fileprivate let ItemShippingInfo  = "SSTShippingInfo"
    fileprivate let ItemShippingPromotion = "SSTItemPromotion"

    fileprivate var itemSlideCell: SSTItemSlideCell?
    
    enum SegueIdentifier: String {
        case toItemDetail = "toItemDetails"
    }
    fileprivate var itemIndToView: Int?
    fileprivate var maskView: UIView?
    
    fileprivate var scrollView: UIScrollView?
    fileprivate var tableView: UITableView!
    fileprivate var leftTbView: UITableView?
    fileprivate var rightTbView: UITableView?
    
    var fromCartVC : Bool = false
    
    fileprivate var isFavoriteButtonEnable = true
    
    fileprivate var currentItem: SSTItem? {
        get {
            if itemData != nil {
                return self.itemData!.items.validObjectAtIndex(validInt(self.itemInd)) as? SSTItem
            } else {
                return self.item
            }
        }
    }
    
    func getSections(item: SSTItem?) -> [String] {
        var sections = [String]()
        if item != nil {
            sections.append("ProductInfo")
        }
//        if validInt(item?.productDiscounts.count) > 0 {
//            sections.append("ProductDiscount")
//        }
        if validString(item?.shippingInfo).isNotEmpty {
            sections.append("ShippingInfo")
        }
        if validInt(item?.freeShippingInfos?.count) > 0 {
            sections.append("ShippingPromotion")
        }
        return sections
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)

        if biz.dealMessage.msgs.count > 0 {
            let loopView = loadNib("\(SSTPromoMsgView.classForCoder())") as! SSTPromoMsgView
            loopView.frame.size = CGSize(width: kScreenWidth, height: kPromoMsgHeight)
            loopView.setDealMessage()
            self.promoMsgView.addSubview(loopView)
            self.promoMsgView.isHidden = false
        } else {
            self.promoMsgView.isHidden = true
        }
        
        scrollView = UIScrollView()
        
        scrollView?.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: scrollViewHeight)
        self.view.addSubview(scrollView!)
        
        scrollView?.isPagingEnabled = true
        scrollView?.backgroundColor = UIColor.groupTableViewBackground
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.contentSize = CGSize(width: kScreenWidth * CGFloat(validInt(self.itemData?.items.count)), height: 0)
        scrollView?.delegate = self
        
        if #available(iOS 11.0, *) {
            scrollView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        if (itemData == nil || itemInd == nil) {
            
            self.tableView = reloadTableView(tableView: tableView, itemInd: 0)
            
            SSTProgressHUD.show(view: self.view)
            SSTItem.fetchDataAndViewLog(itemId: itemId == nil ? validString(item?.id) : validString(itemId)) { [weak self] data, error in
                SSTProgressHUD.dismiss(view: self?.view)
                self?.refreshView(data: data, error: error)
            }
            
            let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
            _ = tableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
                SSTItem.fetchData(itemId: validString(self?.currentItem?.id)) { data, error in
                    self?.refreshView(data: data, error: error)
                }
            }
            
            scrollView?.isScrollEnabled = false
        } else if itemData != nil && itemInd != nil {
            
            self.tableView = reloadTableView(tableView: tableView, itemInd: validInt(itemInd))
            tableView.frame = CGRect(x: kScreenWidth * CGFloat(validInt(self.itemInd)), y: 0, width: kScreenWidth, height: scrollViewHeight)
            scrollView?.addSubview(tableView)
            
            if validInt(self.itemInd) > 0 {
                leftTbView = reloadTableView(tableView: leftTbView, itemInd: validInt(itemInd) - 1)
            }
            if validInt(self.itemInd) < validInt(self.itemData?.items.count) - 1 {
                rightTbView = reloadTableView(tableView: rightTbView, itemInd: validInt(itemInd) + 1)
            } else {
                self.loadMoreItemsForNextPage(tableView: rightTbView, itemInd: validInt(itemInd))
            }
            
            _ = scrollView?.setUpLeftRefresh { [weak self] in
                    _ = self?.navigationController?.popViewController(animated: true)
                }.SetUp({ (lefter) in
                    lefter.setText("", mode: .scrollToAction)
                    lefter.setText("", mode: .releaseToAction)
                })
            
            _ = scrollView?.setUpRightRefresh {
                if validInt(self.itemData?.items.count) < validInt(self.itemData?.numFound) {
                    //
                } else {
                    ToastUtil.showToast(kNoItemsAnyMore)
                }
                }.SetUp({ righter in
                    righter.setText("", mode: .scrollToAction)
                    righter.setText("", mode: .releaseToAction)
                })
        }
        
        scrollView?.contentOffset.x = tableView.frame.origin.x
        
        self.view.addSubview(bottomView)
        self.view.bringSubview(toFront: self.promoMsgView)
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        if itemData != nil && itemInd != nil {
            for itm in validArray(itemData?.items) {
                (itm as? SSTItem)?.promoCountdown = validInt64((itm as? SSTItem)?.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
            }
        } else {
            self.item?.promoCountdown = validInt64(self.item?.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setCartQty()
    }
    
    @objc func viewRefreshWhenCartUpdated() {
        if tableView != nil {
            if let infoCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? SSTItemDetailsInfoCell {
                infoCell.setQtyTFAndButtons()
            }
        }
        self.setCartQty()
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        if getTopVC() == self {
            SSTProgressHUD.show(view: self.view)
            SSTItem.fetchDataAndViewLog(itemId: validString(self.currentItem?.id)) { [weak self] data, error in
                SSTProgressHUD.dismiss(view: self?.view)
                self?.refreshView(data: data, error: error)
            }
        }
    }
    
    func refreshView(data: Any?, error: Any?) {
        if error == nil, let tItem = data as? SSTItem {
            if self.itemInd != nil && self.itemData?.items.validObjectAtIndex(validInt(self.itemInd)) != nil {
                self.itemData?.items[validInt(self.itemInd)] = tItem
            } else {
                self.item = tItem
            }
            
            self.tableView?.reloadData()
            self.tableView.endHeaderRefreshing(.success, delay: 0.5)
            self.setButtons(item: self.currentItem)
        } else {
            self.tableView.endHeaderRefreshing(.failure, delay: 0.5)
        }
    }
    
    // MARK: Scrollview Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            for cell in tableView.visibleCells {
                if let infoCell = cell as? SSTItemDetailsInfoCell {
                    if infoCell.qtyTF.isFirstResponder {
                        infoCell.qtyTF.resignFirstResponder()
                        return
                    }
                }
            }
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isKind(of: UITableView.classForCoder()) {
            return
        }
        let currentPage = validInt((scrollView.contentOffset.x + kScreenWidth * 0.3) / kScreenWidth)
        if currentPage - validInt(itemInd) < -1 || currentPage - validInt(itemInd) >= 1 {
            SSTProgressHUD.show(view: self.view)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isKind(of: UITableView.classForCoder()) {
            return
        }
        let currentPage = validInt((scrollView.contentOffset.x + kScreenWidth * 0.3) / kScreenWidth)
        if currentPage == validInt(itemInd) - 1 {
            itemInd = validInt(itemInd) - 1
            let tmpTableView = rightTbView
            rightTbView = tableView
            tableView = leftTbView
            leftTbView = reloadTableView(tableView: tmpTableView, itemInd: validInt(itemInd) - 1)
            SSTProgressHUD.dismiss(view: self.view)
        } else if currentPage == validInt(itemInd) + 1 {
            itemInd = validInt(itemInd) + 1
            let tmpTableView = leftTbView
            leftTbView = tableView
            tableView = rightTbView
            rightTbView = reloadTableView(tableView: tmpTableView, itemInd: validInt(itemInd) + 1)
            SSTProgressHUD.dismiss(view: self.view)
            
            loadMoreItemsForNextPage(tableView: rightTbView, itemInd: validInt(itemInd))
        } else if currentPage != itemInd {
            itemInd = currentPage
            leftTbView = reloadTableView(tableView: leftTbView, itemInd: validInt(itemInd) - 1)
            tableView = reloadTableView(tableView: tableView, itemInd: validInt(itemInd))
            rightTbView = reloadTableView(tableView: rightTbView, itemInd: validInt(itemInd) + 1)
        }
        
        setButtons(item: self.currentItem)
        SSTItem.addViewLog(validString(self.currentItem?.id))
    }
    
    func loadMoreItemsForNextPage(tableView: UITableView? = nil, itemInd: Int) {
        if itemInd == validInt(self.itemData?.items.count) - 1 {
            if let prevVC = self.navigationController?.childViewControllers[validInt(self.navigationController?.childViewControllers.count) - 2] {
                if prevVC.isKind(of: SSTSearchResultVC.classForCoder()) && validInt(itemData?.items.count) < validInt(itemData?.numFound) {
                    self.itemData?.searchItemsForNextPage() { data, error in
                        if error == nil {
                            self.rightTbView = self.reloadTableView(tableView: tableView, itemInd: validInt(self.itemInd) + 1)
                            self.scrollView?.contentSize = CGSize(width: kScreenWidth * CGFloat(validInt(self.itemData?.items.count)), height: 0)
                        }
                    }
                } else if prevVC.isKind(of: SSTRecentlyViewedVC.classForCoder()) {
                    let recentlyViewedVC = prevVC as! SSTRecentlyViewedVC
                    recentlyViewedVC.browseData.fetchDataForNextPage() { data, error in
                        if error == nil {
                            self.rightTbView = self.reloadTableView(tableView: tableView, itemInd: validInt(self.itemInd) + 1)
                            self.scrollView?.contentSize = CGSize(width: kScreenWidth * CGFloat(validInt(self.itemData?.items.count)), height: 0)
                        }
                    }
                }
            }
        }
    }
    
    func reloadTableView(tableView: UITableView? = nil, itemInd: Int) -> UITableView? {
        
        if itemInd < 0 || ( itemInd > 0 && itemInd >= validInt(itemData?.items.count) ) {
            return UITableView()
        }
        
        let mTableView: UITableView!
        if tableView != nil {
            mTableView = tableView
        } else {
            mTableView = UITableView(frame: CGRect(x: kScreenWidth * CGFloat(itemInd), y: 0, width: kScreenWidth, height: scrollViewHeight), style: .grouped)
            mTableView.backgroundColor = UIColor.groupTableViewBackground
            
            if #available(iOS 11.0, *) {
                mTableView.contentInsetAdjustmentBehavior = .never
            }
        }
        
        mTableView.frame = CGRect(x: kScreenWidth * CGFloat(itemInd), y: 0, width: kScreenWidth, height: scrollViewHeight)
        mTableView.estimatedRowHeight = 44
        mTableView.rowHeight = UITableViewAutomaticDimension
        mTableView.separatorStyle = .none
        mTableView.allowsSelection = false
        mTableView.delegate = self
        mTableView.dataSource = self
        mTableView.reloadData()
        scrollView?.addSubview(mTableView)
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = mTableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            if let tItem = self?.itemData?.items.validObjectAtIndex(itemInd) as? SSTItem {
                SSTItem.fetchData(itemId: validString(tItem.id)) { [weak self] data, error in
                    if error == nil, let nItem = data as? SSTItem {
                        if itemInd >= 0 && itemInd < validInt(self?.itemData?.items.count) {
                            self?.itemData?.items[itemInd] = nItem
                            mTableView?.reloadData()
                        }
                        mTableView.endHeaderRefreshing(.success, delay: 0.5)
                    } else {
                        mTableView.endHeaderRefreshing(.failure, delay: 0.5)
                    }
                }
            }
        }
        if let tItem = self.itemData?.items.validObjectAtIndex(itemInd) as? SSTItem {
            if self.tableView == nil && itemInd == self.itemInd {
                SSTProgressHUD.show(view: self.view)
            }
            SSTItem.fetchData(itemId: validString(tItem.id)) { [weak self] data, error in
                if error == nil, let nItem = data as? SSTItem {
                    if itemInd >= 0 && itemInd < validInt(self?.itemData?.items.count) {
                        self?.itemData?.items[itemInd] = nItem
                        mTableView?.reloadData()
                        if mTableView == self?.tableView {
                            SSTProgressHUD.dismiss(view: self?.view)
                            SSTItem.addViewLog(validString(nItem.id))
                            self?.refreshView(data: data, error: error)
                        }
                    }
                }
            }
        }
        
        mTableView.register(initNib("\(SSTItemDetailsInfoCell.classForCoder())"), forCellReuseIdentifier: kSSTItemDetailsInfoCell)
        
        return mTableView
    }
    
    fileprivate func setButtons(item: SSTItem?) {
        if item?.isFavorite == true {
            favoriteBtn.setImage(UIImage(named: kFavoriteSelectedImgName), for: UIControlState())
        } else {
            favoriteBtn.setImage(UIImage(named: kFavoriteNormalImgName), for: UIControlState())
        }
        
        if validBool(item?.canAddToCart) {
            addToCartButton.isHidden = false
            addToCartButton.isEnabled = true
            soldButton.isHidden = true
        } else if validBool(item?.isUnavailable) {
            addToCartButton.isHidden = false
            addToCartButton.isEnabled = false
            soldButton.isHidden = true
        } else {
            addToCartButton.isHidden = true
            soldButton.isHidden = false
            if item?.isStockReminded == true {
                self.soldButton.setTitle(kItemReminderSubscribed, for: UIControlState())
                self.soldButton.setTitleColor(UIColor.white, for: UIControlState())
            } else {
                self.soldButton.setTitle(kItemGetStockReminder, for: UIControlState())
                self.soldButton.setTitleColor(UIColor.black, for: UIControlState())
            }
        }
    }
    
    func setCartQty() {
        if biz.cart.qty > 0 {
            cartQtyLabel?.text = validString(biz.cart.qty)
        } else {
            cartQtyLabel?.text = ""
        }
    }

    @IBAction func clickedAddtoCartButton(_ sender: AnyObject) {
        if tableView == nil {
            return
        }
        if let tItem = self.currentItem, let infoCell = tableView.dequeueReusableCell(withIdentifier: kSSTItemDetailsInfoCell, for: IndexPath(row: 1, section: 0)) as? SSTItemDetailsInfoCell {
            SSTItem.clickedAddButton(item: tItem, qtyTF: infoCell.qtyTF, minusButton: infoCell.minusButton, addButton: infoCell.addButton, view: self.view, block: {
                let imgV = UIImageView()
                
                if let slideCell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SSTItemSlideCell {
                    if let tmpFrame = slideCell.scrollView.subviews.first?.frame {
                        imgV.frame = tmpFrame
                        imgV.frame.origin = CGPoint(x: imgV.frame.origin.x, y: slideCell.scrollView.frame.origin.y + imgV.frame.origin.y + 64 - self.tableView.contentOffset.y)
                        if slideCell.scrollView.subviews.count <= 1 {
                            imgV.image = (slideCell.scrollView.subviews[0] as! UIImageView).image
                        } else {
                            imgV.image = (slideCell.scrollView.subviews[slideCell.pageControl.currentPage + 1] as! UIImageView).image
                        }
                    }
                } else {
                    imgV.frame = CGRect(x: kScreenWidth * 0.2, y: -self.tableView.contentOffset.y, width: kScreenWidth * 0.6, height: kScreenWidth * 0.6)
                    imgV.setImage(fileUrl: validString(self.currentItem?.images.first), placeholder: kItemDetailPlaceholderImageName)
                }
                
                self.view.addSubview(imgV)
                
                UIView.animate(withDuration: 0.6, animations: {
                    imgV.frame = CGRect(x: self.cartQtyLabel.absoluteX, y: self.cartQtyLabel.absoluteY , width: 5, height: 5)
                }, completion: { (Bool) in
                    imgV.removeFromSuperview()
                })
            })
        }
    }
    
    @IBAction func clickedCartButton(_ sender: AnyObject) {
        self.tabBarController?.selectedIndex = TabIndexType.cart.rawValue
//        if let vc = self.navigationController?.viewControllers.first {
//            if vc.isKind(of: SSTCartVC.classForCoder()) {
//                _ = self.navigationController?.popToRootViewController(animated: true)
//            }
//        }
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK:-- 收藏产品
    @IBAction func clickedFavoriteEvents(_ sender: AnyObject) {
        if self.isFavoriteButtonEnable == false {
            SSTToastView.showError(kOperationTooFastTip)
            return
        }
        
        if let item = self.currentItem {
            if item.isFavorite == true {
                self.isFavoriteButtonEnable = false
                biz.favoriteData.removeItem(item) { (data, error) in
                    self.isFavoriteButtonEnable = true
                    if error == nil {
                        item.isFavorite = false
                        self.favoriteBtn.setImage(UIImage(named: kFavoriteNormalImgName), for: UIControlState())
//                        SSTToastView.showSucceed(kItemRemoveFromFavoriteOK)
                    } else {
//                        SSTToastView.showError(kItemRemoveFromFavoriteFailed)
                    }
                }
            } else {
                self.isFavoriteButtonEnable = false
                biz.favoriteData.addItem(item) { (data, error) in
                    self.isFavoriteButtonEnable = true
                    if error == nil {
                        item.isFavorite = true
                        self.favoriteBtn.setImage(UIImage(named: kFavoriteSelectedImgName), for: UIControlState())
//                        SSTToastView.showSucceed(kItemAddToFavoriteSuccessfully)
                    } else {
//                        SSTToastView.showError(kItemAddToFavoriteFailed)
                    }
                }
            }
        }
    }
    
    //MARK:-- set stock remind or cancel stock remind
    @IBAction func getStockReminderEvent(_ sender: AnyObject) {
        if let item = self.currentItem {
            if item.isStockReminded == true { //cancel remind
                SSTItemData.cancelStockNotification(item.id, callback: { (message) in
                    if validInt(message) == 200 {
                        self.soldButton.setTitle(kItemGetStockReminder, for: UIControlState())
                        self.soldButton.setTitleColor(UIColor.black, for: UIControlState())
                        SSTToastView.showSucceed(kItemCancelSubscriptionSuccessfully)
                    } else {
                        SSTToastView.showError(validString(message))
                    }
                })
            } else { //set stock remind
                SSTItemData.saveStockNotifications(item.id, callback: { (message) in
                    if validInt(message) == 200 {
                        self.soldButton.setTitle(kItemReminderSubscribed, for: UIControlState())
                        self.soldButton.setTitleColor(UIColor.white, for: UIControlState())
                        SSTToastView.showSucceed(kItemSubscribeSuccessfully)
                    } else {
                        SSTToastView.showError(validString(message))
                    }
                })
            }
        }
    }
    
    @objc func timerAlarm() {
        if itemData != nil && itemInd != nil {
            for ind in 0 ..< validInt(itemData?.items.count) {
                (itemData?.items.validObjectAtIndex(ind) as? SSTItem)?.minusOneToPromoCountdown()
            }
        } else {
            item?.minusOneToPromoCountdown()
        }
        if tableView != nil {
            if let slideCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SSTItemSlideCell {
                slideCell.refreshCountdown()
            }
        }
    }
    
    func getItemForTbV(tableView: UITableView) -> SSTItem? {
        if itemData != nil && itemInd != nil {
            let currentPage = validInt((tableView.frame.origin.x + kScreenWidth * 0.3) / kScreenWidth)
            if currentPage < validInt(itemInd) {
                if let tmpItem = self.itemData?.items.validObjectAtIndex(validInt(self.itemInd) - 1) as? SSTItem {
                    return tmpItem
                }
            } else if currentPage > validInt(itemInd) {
                if let tmpItem = self.itemData?.items.validObjectAtIndex(validInt(self.itemInd) + 1) as? SSTItem {
                    return tmpItem
                }
            } else {
                if let tmpItem = self.itemData?.items.validObjectAtIndex(validInt(self.itemInd)) as? SSTItem {
                    return tmpItem
                }
            }
        }
        
        return self.item
    }
}

// MARK: -- tableView delegate

extension SSTItemDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let item = getItemForTbV(tableView: tableView)
        return getSections(item: item).count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = getItemForTbV(tableView: tableView)
        let sections = getSections(item: item)
        if sections[section] == "ProductInfo" {
            if validBool(item?.isPromoItem) && validInt64(item?.promoCountdown) > 0 {
                return 4
            } else {
                return 3
            }
        } else if sections[section] == "ProductDiscount" {
            return validInt(item!.productDiscounts.count)
        }  else if sections[section] == "ShippingInfo" {
            return 2
        } else if sections[section] == "ShippingPromotion" {
            return validInt(item!.shippingPromotions?.count) + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return kScreenWidth * 0.55 + 36 * 2
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let item = getItemForTbV(tableView: tableView)
        if section == getSections(item: item).count - 1 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = getItemForTbV(tableView: tableView)
        let sections = getSections(item: item)
        
        var cell: UITableViewCell! = UITableViewCell()
        
        let sectionName = validString(sections.validObjectAtIndex(indexPath.section))
        if sectionName == "ProductInfo" {
            if indexPath.row == 0 {
                cell = loadNib("\(SSTItemSlideCell.classForCoder())") as! SSTBaseCell
                itemSlideCell = cell as? SSTItemSlideCell
                itemSlideCell?.item = item
                itemSlideCell?.itemClick = { ind in
                    let vc = SSTImageViewVC()
                    vc.indexPath = IndexPath(row: validInt(ind), section: 0)
                    vc.imgUrls = item?.originImages
                    vc.modalPresentationStyle = .custom
                    self.present(vc, animated: false, completion: nil)
                }
            } else if indexPath.row == 1 {
                let infoCell = tableView.dequeueReusableCell(withIdentifier: "SSTItemDetailsInfoCell")  as! SSTItemDetailsInfoCell
                infoCell.item = item
                cell = infoCell
            } else if indexPath.row == 2 { // product info
                if validBool(item?.isPromoItem) && validInt64(item?.promoCountdown) > 0 {
                    dailyDealsCell = loadNib("\(SSTDailyDealsCell.classForCoder())") as! SSTDailyDealsCell
                    dailyDealsCell.messageLabel.text = String(format: kItemDailyDealsText1, validDouble(item?.price).formatC(), validInt(item?.promoMaxQtyPerUser), validInt(item?.promoMaxQtyPerUser) == 1 ? "" : "s", validDouble(item?.listPrice).formatC())
                    cell = dailyDealsCell
                } else {
                    sKUViewCell = loadNib("\(SSTSKUViewCell.classForCoder())") as! SSTSKUViewCell
                    sKUViewCell.messageLabel.text = item?.sku
                    cell = sKUViewCell
                }
            } else if indexPath.row == 3 { // SKU
                sKUViewCell = loadNib("\(SSTSKUViewCell.classForCoder())") as! SSTSKUViewCell
                sKUViewCell.messageLabel.text = item?.sku
                cell = sKUViewCell
            }
        } else if sectionName == "ProductDiscount" {
            cell = loadNib("\(SSTProductDiscountCell.classForCoder())") as! SSTProductDiscountCell
            (cell as! SSTProductDiscountCell).productDiscount = item?.productDiscounts[indexPath.row]
        } else if sectionName == "ShippingInfo" {
            if indexPath.row == 0 {
                cell = UITableViewCell()
                cell.textLabel?.text = "Shipping Info"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                let bottonLine = UIView(frame: CGRect(x:15, y: cell.height - 1, width: kScreenWidth - 15, height: 1))
                bottonLine.backgroundColor = UIColor.groupTableViewBackground
                cell.addSubview(bottonLine)
            } else {
                cell = loadNib("\(SSTItemShippingInfoCell.classForCoder())") as! SSTItemShippingInfoCell
                let shippinginfoL = cell.viewWithTag(0001) as! UILabel
                shippinginfoL.text = item?.shippingInfo
            }
        } else if sectionName == "ShippingPromotion" {
            if indexPath.row == 0 {
                cell = UITableViewCell()
                cell.textLabel?.text = "Shipping Promotions"
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                let bottonLine = UIView(frame: CGRect(x:15, y:cell.height - 1, width: kScreenWidth - 15, height: 1))
                bottonLine.backgroundColor = UIColor.groupTableViewBackground
                cell.addSubview(bottonLine)
            } else {
                cell = loadNib("\(SSTItemPromotion.classForCoder())") as! SSTItemPromotion
                if let tInfo = item?.freeShippingInfos?.validObjectAtIndex(indexPath.row - 1) as? SSTFreeShippingInfo {
                    (cell as? SSTItemPromotion)?.info = tInfo
                }
                return cell
            }
        }
        
        return cell
    }
}
