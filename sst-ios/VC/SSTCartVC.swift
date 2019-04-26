//
//  SSTShoppingCartTabVC.swift
//  sst-mobile
//
//  Created by Amy on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit

let kCartCellHeight: CGFloat            = 118
let kCartCellTimerViewHeight: CGFloat   = 15
let kCartCellPromoViewHeight: CGFloat   = 12
let kCartPayViewHeight: CGFloat         = 49

class SSTCartVC: SSTBaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var leftBarButton: UIButton!
    @IBOutlet weak var rightBarButton: UIButton!
    
    let cellPayView = loadNib("\(SSTCartPayView.classForCoder())") as! SSTCartPayView
    let viewPayView = loadNib("\(SSTCartPayView.classForCoder())") as! SSTCartPayView
    
    fileprivate var bestSellingData = SSTBestSelling()
    fileprivate var recommendTypeClicked = kCartBestSelling
    
    fileprivate var itemClicked: SSTItem?
    
    fileprivate let kSSTEmptyBestOrMostPopularViewId       = "SSTEmptyBestOrMostPopularView"
    fileprivate let kEmptyCartCellId        = "SSTEmptyCartCell"
    fileprivate let kCartItemCellId         = "SSTCartCell"
    fileprivate let kRecommendItemCellId    = "SSTBestSellingCell"
    fileprivate let kBlankHeaderView        = "SSTBlankHeaderView"
    fileprivate let kRecommendHeadViewId    = "SSTBestSellingHeadView"
    fileprivate let kDiscountMsgViewId      = "SSTDiscountInfoView"
    
    fileprivate var bestSellingEmtpyCellHeight: CGFloat {
        get {
            return kScreenHeight / 3
        }
    }
    
    fileprivate func getCartCellHeight(item: SSTCartItem) -> CGFloat {
        var cartCellHeight = kCartCellHeight
        if item.promoQty > 0 {
            if validInt64(item.promoCountdown) > 0 {
                cartCellHeight += kCartCellTimerViewHeight
            }
            if item.promoCountContained > 0 {
                cartCellHeight += kCartCellPromoViewHeight
            }
        }
        return cartCellHeight
    }
    
    fileprivate var allCartItemCellsHeight: CGFloat {
        get {
            var height: CGFloat = 0
            for itm in biz.cart.items {
                height += getCartCellHeight(item: itm)
            }
            return height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(initNib("\(SSTBestSellingCell.classForCoder())"), forCellWithReuseIdentifier: kRecommendItemCellId)
        
        collectionView.register(initNib("\(SSTBestSellingHeadView.classForCoder())"), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kRecommendHeadViewId)
        collectionView.register(initNib("\(kBlankHeaderView)"), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBlankHeaderView)
        collectionView.register(initNib("\(SSTDiscountInfoView.classForCoder())"), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kDiscountMsgViewId)
        
        collectionView.register(SSTEmptyBestOrMostPopularView.classForCoder(), forCellWithReuseIdentifier: kSSTEmptyBestOrMostPopularViewId)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        leftBarButton.frame.size = CGSize(width: 1, height: 30)
        rightBarButton.setTitle("", for: .normal)
        
        biz.cart.delegate = self
        bestSellingData.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        biz.cart.fetchData()
        bestSellingData.fetchData()
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = collectionView.setUpHeaderRefresh(refreshHeaderView) {
            biz.cart.fetchData()
            self.bestSellingData.fetchData()
        }
        
        viewPayView.checkoutButtonClick = {
            self.clickedCheckOutButton()
        }
        cellPayView.checkoutButtonClick = {
            self.clickedCheckOutButton()
        }
        viewPayView.frame = CGRect(x: 0, y: kScreenHeight - kScreenTabbarHeight - payViewHeight, width: kScreenWidth, height: payViewHeight)
        self.view.addSubview(viewPayView)
        setPayView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
        
        if biz.cart.isUpdating {
            SSTProgressHUD.show(view: self.view)
        }
        
        setTitleViewOnNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        biz.cart.fetchData()
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        biz.cart.fetchData()
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        for itm in biz.cart.items {
            itm.promoCountdown = validInt64(itm.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
        
        biz.cart.fetchData()
        if gLatestApplicatonDidBecomeActiveDateYYYYMMDD != Date().formatYYYYMMDD() {
            bestSellingData.fetchData()
        }
    }
    
    @IBAction func clickedShopMoreButton(_ sender: Any) {
        clickedGoShoppingButton(sender as AnyObject)
    }
    
    func setTitleViewOnNavigationBar() {
        let tmpAttributedString = SSTDealMessage.toAttributedString(validString(biz.cart.currentLevelDiscountTip), color: "#292929")
        if biz.cart.items.count > 0 && validBool(tmpAttributedString.string.isNotEmpty) {
            self.navigationItem.title = ""
            let leftLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tmpAttributedString.size().width, height: 30))
            leftLabel.attributedText = tmpAttributedString
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftLabel)
            rightBarButton.setTitle("Shop more", for: .normal)
            rightBarButton.frame.size = CGSize(width: 85, height: 30)
            rightBarButton.isEnabled = true
            rightBarButton.isHidden = tmpAttributedString.size().width > kScreenWidth - 85 - 30
        } else {
            self.navigationItem.title = "Cart"
            self.navigationItem.leftBarButtonItem = nil
            rightBarButton.setTitle("", for: .normal)
            rightBarButton.frame.size = CGSize(width: 0.1, height: 30)
            rightBarButton.isEnabled = false
        }
    }
    
    // MARK: -- cart pay view
    
    var payViewHeight: CGFloat {
        get {
            if biz.cart.tipsOfOrderDiscountAndFreeShippingCompany.count > 0 {
                return 35 + 49
            } else {
                return 49
            }
        }
    }
    
    func setPayViewFrame() {
        if biz.cart.items.count > 0 {
            if allCartItemCellsHeight - collectionView.contentOffset.y > kScreenViewHeight - payViewHeight {
                viewPayView.isHidden = false
                viewPayView.frame = CGRect(x: 0, y: kScreenHeight - kScreenTabbarHeight - payViewHeight, width: kScreenWidth, height: payViewHeight)
            } else if collectionView.contentOffset.y >= allCartItemCellsHeight {
                viewPayView.isHidden = false
                viewPayView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: payViewHeight)
            } else {
                viewPayView.isHidden = true
            }
        } else {
            viewPayView.isHidden = true
        }
    }
    
    func setPayView() {
        setPayViewFrame()
        
        viewPayView.setPromoMsgView()
        cellPayView.setPromoMsgView()
        viewPayView.setData(biz.cart.orderItemsTotal, oldAmount: biz.cart.orderTotal, count: biz.cart.qty)
        cellPayView.setData(biz.cart.orderItemsTotal, oldAmount: biz.cart.orderTotal, count: biz.cart.qty)
    }

    @IBAction func clickedGoShoppingButton(_ sender: AnyObject?) {
        self.tabBarController?.selectedIndex = TabIndexType.home.rawValue
        if let vc = self.navigationController?.viewControllers.first {
            if vc.isKind(of: SSTHomeVC.classForCoder()) {
                _ = self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}

// MARK: -- collectionView delegate

extension SSTCartVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if validArray(bestSellingData.itemsDict[kCartBestSelling]).count > 0 || validArray(bestSellingData.itemsDict[kCartMostPopular]).count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return biz.cart.items.count > 0 ? biz.cart.items.count + 1 : 1
        } else {
            let items = bestSellingData.itemsDict[recommendTypeClicked]
            if validInt(items?.count) > 0 {
                return validInt(bestSellingData.itemsDict[recommendTypeClicked]?.count)
            } else {
                return 1
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 && biz.cart.items.count == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kEmptyCartCellId, for: indexPath) as! SSTEmptyCartCell
                return cell
            } else if indexPath.row < biz.cart.items.count {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCartItemCellId, for: indexPath) as! SSTCartCell
                if let item = biz.cart.items.validObjectAtIndex(indexPath.row) as? SSTCartItem {
                    cell.item = item
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SSTXib", for: indexPath)
                cellPayView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: payViewHeight)
                cell.addSubview(cellPayView)
                return cell
            }
        } else {
            let items = bestSellingData.itemsDict[recommendTypeClicked]
            if validInt(items?.count) > 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kRecommendItemCellId, for: indexPath) as! SSTBestSellingCell
                if let tItem = items?.validObjectAtIndex(indexPath.row) as? SSTItem {
                    cell.item = tItem
                }
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kSSTEmptyBestOrMostPopularViewId, for: indexPath) as! SSTEmptyBestOrMostPopularView
                let emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
                emptyView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: bestSellingEmtpyCellHeight)
                emptyView.setData(imgName: kIcon_badConnected, msg: kNoBalanceOrderTip, buttonTitle: "", buttonVisible: false)
                cell.addSubview(emptyView)
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for cell in collectionView.visibleCells {
            if cell.isKind(of: SSTCartCell.classForCoder()) {
                (cell as! SSTCartCell).qtyTF.resignFirstResponder()
            }
        }
        if indexPath.section == 0 {
            if indexPath.row < biz.cart.items.count {
                itemClicked = biz.cart.items[indexPath.row] as SSTItem
                self.performSegue(withIdentifier: SegueIdentifier.toItemDetail.rawValue, sender: self)
            }
        } else {
            let items = bestSellingData.itemsDict[recommendTypeClicked]
            if validInt(items?.count) > 0 {
                if let tItem = items?.validObjectAtIndex(indexPath.row) {
                    itemClicked = tItem as? SSTItem
                    self.performSegue(withIdentifier: SegueIdentifier.toItemDetail.rawValue, sender: self)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemSize = CGSize.zero
        if indexPath.section == 0 {
            if biz.cart.items.count > 0 {
                if indexPath.row < biz.cart.items.count, let item = biz.cart.items.validObjectAtIndex(indexPath.row) as? SSTCartItem {
                    itemSize = CGSize(width: kScreenWidth, height: getCartCellHeight(item: item))
                } else {
                    itemSize = CGSize(width: kScreenWidth, height: self.payViewHeight)
                }
            } else {
                if validInt(bestSellingData.itemsDict[kCartBestSelling]?.count) == 0 && validInt(bestSellingData.itemsDict[kCartMostPopular]?.count) == 0 {
                    itemSize = CGSize(width: kScreenWidth, height: kScreenViewHeight)
                } else {
                    itemSize = CGSize(width: kScreenWidth, height: 245)
                }
            }
        } else if indexPath.section == 1 {
            let items = bestSellingData.itemsDict[recommendTypeClicked]
            if validInt(items?.count) > 0 {
                itemSize = CGSize(width: (kScreenWidth - 1.1) * 0.5, height: kCartBestSellingCellHeight - 20)
            } else {
                itemSize = CGSize(width: kScreenWidth, height: bestSellingEmtpyCellHeight)
            }
        }
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: kScreenWidth, height: 0.1)
        } else if section == 1 {
            return CGSize(width: kScreenWidth, height: 42)
        }
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var headView = UICollectionReusableView()
        if kind == UICollectionElementKindSectionHeader {
            if indexPath.section == 0 {
                headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBlankHeaderView, for: indexPath) as! SSTBlankHeaderView
            } else if indexPath.section == 1 {
                let hv = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kRecommendHeadViewId, for: indexPath) as! SSTBestSellingHeadView
                hv.selectTypeInCartBlock = { [weak self] type in
                    self?.recommendTypeClicked = type
                    self?.collectionView.reloadData()
                }
                headView = hv
            }
        }
        
        return headView
    }
    
    @objc func timerAlarm() {
        for ind in 0 ..< biz.cart.items.count {
            if let tmpItem = biz.cart.items.validObjectAtIndex(ind) as? SSTCartItem {
                tmpItem.minusOneToPromoCountdown()
            }
        }
        
        for ind in 0 ..< validInt(bestSellingData.itemsDict[kCartBestSelling]?.count) {
            if let tmpItem = bestSellingData.itemsDict[kCartBestSelling]?.validObjectAtIndex(ind) as? SSTItem {
                tmpItem.minusOneToPromoCountdown()
            }
        }
        
        for ind in 0 ..< validInt(bestSellingData.itemsDict[kCartMostPopular]?.count) {
            if let tmpItem = bestSellingData.itemsDict[kCartMostPopular]?.validObjectAtIndex(ind) as? SSTItem {
                tmpItem.minusOneToPromoCountdown()
            }
        }
        
        for cell in collectionView.visibleCells {
            if cell.isKind(of: SSTCartCell.classForCoder()) {
                if let item = (cell as! SSTCartCell).item {
                    let timeLabel = cell.viewWithTag(9) as! UILabel
                    timeLabel.text = "\(item.promoCountdownText)"
                }
            } else if cell.isKind(of: SSTBestSellingCell.classForCoder()) {
                if let item = (cell as! SSTBestSellingCell).item {
                    let timeLabel = (cell as! SSTBestSellingCell).itemV.viewWithTag(008) as! UILabel
                    timeLabel.text = "\(item.promoCountdownText)"
                }
            }
        }
    }

}

extension SSTCartVC: SSTCheckOutDelegate {
    func clickedCheckOutButton() {
        guard biz.cart.qty > 0 else {
            return
        }
        
        var notOKForCheckoutItmCnt = 0
        for itm in biz.cart.items {
            if itm.isUnavailable || !itm.inStock {
                notOKForCheckoutItmCnt += 1
            }
        }
        if notOKForCheckoutItmCnt > 0 {
            let mAC = UIAlertController(title: "", message: (notOKForCheckoutItmCnt == 1 ? kItemNotOkForCheckoutTip : kItemsNotOkForCheckoutTip), preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            mAC.addAction(okAction)
            self.present(mAC, animated: true, completion: nil)
            return
        }
        
        guard biz.user.isLogined else {
            presentLoginVC({ [weak self] (data, error) in
                if biz.user.isLogined {     // the cart will fetch cart data after logining
                    self?.clickedCheckOutButton()
                }
            })
            return
        }
        navToOrderConfirmVC()
    }
    
    func navToOrderConfirmVC() {
        if biz.cart.isUpdating {
            SSTToastView.showError(kOperationTooFastTip)
            return
        }
        self.performSegue(withIdentifier: SegueIdentifier.toOrderConfirm.rawValue, sender: self)
    }
}

// MARK: -- UIScrollViewDelegate

extension SSTCartVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            if let cartCell = cell as? SSTCartCell {
                if cartCell.qtyTF.isFirstResponder {
                    cartCell.qtyTF.resignFirstResponder()
                    return
                }
            } else if let bestSellingCell = cell as? SSTBestSellingCell {
                if bestSellingCell.itemV.qtyTF.isFirstResponder {
                    bestSellingCell.itemV.qtyTF.resignFirstResponder()
                    return
                }
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setPayViewFrame()
    }
}

// MARK: -- Segue delegate

extension SSTCartVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case toItemDetail   = "toItemDetail"
        case toOrderConfirm = "toOrderConfirm"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toItemDetail.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            destVC.fromCartVC = true
            destVC.item = itemClicked
        default:
            break
        }
    }
}

// MARK: - SSTUIRefreshDelegate

extension SSTCartVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        
        collectionView.reloadData()
        
        if (data as? SSTBestSelling) != nil {
            return
        }
        
        SSTProgressHUD.dismiss(view: self.view)
        
        collectionView.performBatchUpdates({
            //
        }, completion: { (Bool) in
            self.setPayView()
        })
        
        if (data as? SSTCart) != nil {
            collectionView.endHeaderRefreshing(.success, delay: 0.5)
            setTitleViewOnNavigationBar()
        } else {
            collectionView.endHeaderRefreshing(.failure, delay: 0.5)
        }
    }
}
