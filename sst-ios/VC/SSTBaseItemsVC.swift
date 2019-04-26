//
//  SSTBaseItemsVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 7/13/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kDefaultFooterHeight: CGFloat = 44

let kStyleListImageName = "result_icon_line"
let kStyleGridImageName = "result_icon_inter"

let kItemViewResueCount = 10

let kSearchResultViewGridWidth  = kScreenWidth / 2
let kSearchResultViewGridHeight = kScreenWidth / 2 + 50
let kSearchResultViewListHeight = kSearchResultViewGridHeight / 2

class SSTBaseItemsVC: SSTBaseSearchVC, SSTUIRefreshDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var goTopButton: UIButton!
    
    var itemData = SSTItemData()
    var itemViews = [SSTSearchResultView]()  // this array used to reuse in scrollView, and only hold six view
    var itemViewsBgV = UIView()
    
    var layoutStyle = SearchResultLayoutStyle.grid
    var scrollViewFrameHeight = kScreenHeight - kScreenNavigationHeight - kScreenTabbarHeight + kDefaultFooterHeight
    var scrollViewContentOffset = CGPoint.zero
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    var spacing:CGFloat = 0
    var columnsNum = 0
    var itemWidth: CGFloat = 0.0
    var itemHeight: CGFloat {
        get {
            if layoutStyle == .grid {
                return kSearchResultViewGridHeight
            } else {
                return kSearchResultViewListHeight
            }
        }
    }
    
    var itemsVisibleH: CGFloat = 0.0
    var scrollViewVisiableRectTopOffsetY: CGFloat {
        get {
            return itemViewsBottomY - itemsVisibleH
        }
    }
    var scrollViewVisiableRectBottomOffsetY: CGFloat {
        get {
            return scrollView.contentOffset.y + scrollViewFrameHeight
        }
    }
    
    var itemViewsTopY: CGFloat {
        get {
            return CGFloat(validDouble(itemViews.first?.y))
        }
    }
    var itemViewsBottomY: CGFloat {
        get {
            if itemViews.count > 0 {
                let maxDataIndex = validInt(itemViews.last?.tag)     // cause move the two itemViews every time
                if layoutStyle == .grid {
                    return CGFloat( (maxDataIndex + 2) / 2) * itemHeight
                } else {
                    return CGFloat(maxDataIndex + 1) * itemHeight
                }
            } else {
                return 0
            }
        }
    }
    
    var itemViewsBgVHeight: CGFloat {
        get {
            var bottomY: CGFloat = 0
            let dataInd = validInt(itemViews.last?.tag)
            if layoutStyle == .grid {
                bottomY = CGFloat( (dataInd + 1) / 2 ) * itemHeight
            } else {
                bottomY = itemData.items.count % 2 == 0 ? CGFloat( dataInd + 1 ) * itemHeight : CGFloat( dataInd ) * itemHeight
            }
            return bottomY - itemViewsTopY
        }
    }
    
    enum SegueIdentifier: String {
        case toItemDetail      = "toItemDetails"
        case toSearchResult    = "toSearchResult"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        scrollView.delegate = self
        itemData.delegate = self
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = scrollView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.upPullLoadData()
        }
        _ = scrollView.setUpFooterRefresh { [weak self] in
            self?.downPullLoadData()
            }.SetUp { (footer) in
                setRefreshFooter(footer)
        }
        
        self.itemViewsBgV.backgroundColor = UIColor.white
        self.scrollView.addSubview(itemViewsBgV)
        
        updateItemWH()
        updateScrollViewFrame()
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight)
        emptyView.setData(imgName: kIcon_badConnected, msg: kNoResultTip, buttonTitle: kButtonTitleTryAgain, buttonVisible: true)
        emptyView.buttonClick = {
            self.upPullLoadData()
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        
        SSTItemData.getStockNotifications()
    }
    
    @objc func viewRefreshWhenCartUpdated() {
        for itmV in itemViews {
            itmV.setQtyTFAndButtons()
        }
    }
    
    func fetchItems(start: Int? = 0) {
        // need to override in order to fetch items to display
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        for itm in itemData.items {
            itm.promoCountdown = validInt64(itm.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
    }
    
    // MARK: - XWSwiftRefresh
    
    func upPullLoadData() {
        scrollViewContentOffset = CGPoint.zero
        self.fetchItems()
    }
    
    func downPullLoadData() {
        scrollViewContentOffset = scrollView.contentOffset
        if itemData.items.count < itemData.numFound {
            self.fetchItems(start: self.itemData.items.count)
        } else {
            scrollView.endFooterRefreshingWithNoMoreData()
        }
    }
    
    @IBAction func clickedGoTopButton(_ sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x:0, y:0, width: scrollView.width, height: scrollView.height), animated: true)
    }
    
    func updateItemWH() {
        if layoutStyle == .grid {
            spacing = 1
            columnsNum = 2
            itemWidth = kScreenWidth / 2
            itemsVisibleH = itemHeight * ceil(CGFloat(kItemViewResueCount) / 2.0)
            scrollView.contentSize = CGSize(width: kScreenWidth, height: itemHeight * CGFloat((itemData.items.count + 1) / 2) )
        } else {
            spacing = 0
            columnsNum = 1
            itemWidth = (kScreenWidth - spacing * CGFloat(columnsNum - 1)) / CGFloat(columnsNum)
            itemsVisibleH = itemHeight * CGFloat(kItemViewResueCount)
            scrollView.contentSize = CGSize(width: kScreenWidth, height: itemHeight * CGFloat(itemData.items.count))
        }
    }
    
    fileprivate func updateItemViewFrameOrigin(_ itemV: SSTSearchResultView) {
        if itemV.tag < 0 || itemV.tag >= itemData.items.count {
            return
        }
        if layoutStyle == .list {
            itemV.frame.origin = CGPoint(x: 0, y: self.itemHeight * CGFloat(itemV.tag) + 1)
        } else {
            itemV.frame.origin = CGPoint(x: (itemWidth + 1) * CGFloat(itemV.tag % 2), y: itemHeight * CGFloat(itemV.tag / 2) + 1)
        }
    }
    
    func updateScrollViewFrame() {
        for ind in 0 ..< itemViews.count {
            let itemV = itemViews[ind]
            
            updateItemViewFrameOrigin(itemV)
            itemV.frame.size = CGSize(width: itemWidth, height: itemHeight-1)
            itemV.layout = layoutStyle
            
            itemV.setQtyTFAndButtons()
        }
    }
    
    func updateItemVDisplay(_ itemV: SSTSearchResultView) {
        if itemV.tag < 0 || itemV.tag >= itemData.items.count {
            //            itemV.alpha = 0.01
        } else {
            itemV.alpha = 1
            itemV.item = itemData.items[itemV.tag]
            
            updateItemViewFrameOrigin(itemV)
        }
    }
    
    func initScrollView() {
        
        for vw in itemViews {
            vw.removeFromSuperview()
        }
        itemViews.removeAll()
        
        for ind in 0 ..< kItemViewResueCount {
            if ind >= itemData.items.count {
                break
            }
            let itemV = SSTSearchResultView(frame: CGRect(x: 0, y: 0, width: itemWidth, height: itemHeight))
            
            scrollView.addSubview(itemV)
            itemViews.append(itemV)
            
            itemV.tag = ind
            updateItemVDisplay(itemV)
            
            itemV.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(SSTSearchResultVC.clickedItemView(_:)))
            itemV.addGestureRecognizer(tap)
        }
        updateScrollViewFrame()
    }
    
    func updateScrollView() {
        self.itemViewsBgV.frame = CGRect(x: 0, y: itemViewsTopY, width: kScreenWidth, height: itemViewsBgVHeight)
        self.itemViewsBgV.alpha = 1
        UIView.animate(withDuration: 0.3, animations: {
            self.updateScrollViewFrame()
        }, completion: { (true) in
            self.itemViewsBgV.alpha = 0.1
        })
    }
    
    func setStyleImage() {
        //
    }
    
    func updateItemViewStyle() {
        if layoutStyle == .grid {
            layoutStyle = .list
        } else {
            layoutStyle = .grid
        }
        setStyleImage()
        updateItemWH()
        updateScrollView()
    }
    
    @objc func clickedItemView(_ sender: UITapGestureRecognizer) {
        if let ind = sender.view?.tag {
            if (itemData.items.validObjectAtIndex(ind) as? SSTItem) != nil {
                itemClicked = nil
                itemIndClicked = ind
                performSegue(withIdentifier: SegueIdentifier.toItemDetail.rawValue, sender: self)
            } else {
                SSTToastView.showError(kItemmOutOfDate)
            }
        }
    }
    
    @objc func timerAlarm() {
        for item in itemData.items {
            item.minusOneToPromoCountdown()
        }
        for itemV in itemViews {
            itemV.refreshCountdown()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toItemDetail.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            if itemClicked != nil {
                destVC.item = itemClicked
            } else {
                destVC.itemData = SSTItemData(itmData: itemData)
                destVC.itemInd = itemIndClicked
            }
        default:
            break
        }
    }

    // MARK: -- UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for itemV in itemViews {
            if itemV.qtyTF.isFirstResponder {
                itemV.qtyTF.resignFirstResponder()
                return
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > itemHeight * 10 * (layoutStyle == .grid ? 0.5 : 1) {
            goTopButton.isHidden = false
        } else {
            goTopButton.isHidden = true
        }
        
        for _ in 0...1000 {
            if scrollViewVisiableRectBottomOffsetY > itemViewsBottomY && itemViewsBottomY + itemHeight * 0.75 <= scrollView.contentSize.height {
                showItemView(itemViewsBottomY + itemHeight * 0.75, direction: "DOWN")
            } else {
                break
            }
        }
        for _ in 0...1000 {
            if scrollView.contentOffset.y < itemViewsTopY && itemViewsTopY - itemHeight * 0.75 >= 0 {
                showItemView(itemViewsTopY - itemHeight * 0.75, direction: "UP")
            } else {
                break
            }
        }
    }
    
    func showItemView(_ scrollViewItemY: CGFloat, direction: String) {
        
        if itemViews.count < 2 {
            return
        }
        
        var dataIndex = Int( scrollViewItemY / scrollView.contentSize.height * CGFloat(itemData.items.count + itemData.items.count % 2) )
        if layoutStyle == .list {
            dataIndex = Int( scrollViewItemY / scrollView.contentSize.height * CGFloat(itemData.items.count) )
        }
        
        dataIndex = dataIndex - dataIndex % 2
        if dataIndex % 2 == 1 {
            printDebug("data Index is error!")
        }
        
        if dataIndex < 0 || dataIndex >= itemData.items.count {
            return
        }
        
        var itemV1: SSTSearchResultView!
        var itemV2: SSTSearchResultView!
        if direction == "DOWN" {
            itemV1 = itemViews[0]
            itemV2 = itemViews[1]
        } else {
            itemV1 = itemViews[itemViews.count - 2]
            itemV2 = itemViews[itemViews.count - 1]
        }
        
        itemV1.tag = dataIndex
        itemV2.tag = dataIndex + 1
        
        updateItemVDisplay(itemV1)
        updateItemVDisplay(itemV2)
        
        if direction == "DOWN" {
            itemViews.removeFirst()
            itemViews.removeFirst()
            itemViews.append(itemV1)
            itemViews.append(itemV2)
        } else {
            itemViews.removeLast()
            itemViews.removeLast()
            itemViews.insert(itemV1, at: 0)
            itemViews.insert(itemV2, at: 1)
        }
    }
    
    // MARK: -- SSTUIRefreshDelegate
    
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        
        if (data as? SSTItemData) == nil {
            scrollView.endHeaderRefreshing(.failure, delay: 0.9)
        } else {
            scrollView.endHeaderRefreshing(.success, delay: 0.9)
            
            if itemData.items.count < itemData.numFound {
                scrollView.endFooterRefreshing()
            } else {
                scrollView.endFooterRefreshingWithNoMoreData()
            }
            
            if scrollViewContentOffset == CGPoint.zero {
                initScrollView()
            } else {
                scrollView.setContentOffset(CGPoint(x: scrollViewContentOffset.x, y: scrollViewContentOffset.y + itemHeight * 0.5), animated: true)
            }
            
            updateItemWH()
        }
        
        emptyView.isHidden = self.itemData.items.count <= 0 ? false : true
    }
}
