//
//  SSTHomeVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/12/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import PullToRefreshKit

let kHomeSlideHeight: CGFloat = kScreenWidth / 4.122
let kHomeDailyDealsCellWidth: CGFloat = 150
let kHomeDailyDealsCellHeight: CGFloat = kHomeDailyDealsCellWidth + 15
let kHomeBannerCellHeight: CGFloat = 70

let kHomeCategoryCellHeight = kScreenWidth / 2 + 15
let kHomeCategoryCellSize = CGSize(width: (kScreenWidth - 1.1) * 0.5, height: kHomeCategoryCellHeight)

let kHomeVersionTimeFileName = "VersionTime"
let kHomeForceUpdate = "forceUpdate"

let kHomePromoInfomationTimeFileName = "PromoInfomationTime"

class SSTHomeVC: SSTBaseSearchVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var msgButton: UIButton!
    
    let kBlankViewId = "BlankView"
    let kCategoryHeadViewId = "CategoryHeadView"
    let kDealsCellId = "DealsCell"
    let kBannerCellId = "BannerCell"
    let kItemCellId = "ItemCell"
    
    fileprivate var homeData = SSTHomeData()
    fileprivate var discountInformation = SSTDiscountInformation()
    fileprivate var messageData = SSTMessageData()
    
    fileprivate var messageView: SSTHomeMessageView?
    
    fileprivate var messageClicked: SSTMessage?
    fileprivate var categoryClicked: SSTCategory?
    fileprivate var homeSeeAll: HomeSeeAllType?
    
    var webTitle: String?
    var webHtmlString: String?
    var webUrl: String?
    var msgId: String?
    
    var articleId: String?
    var orderId:String?
    
    enum SegueIdentifier: String {
        case toSeeAll           = "toSeeAll"
        case toSearchResult     = "toSearchResult"
        case toItemDetail       = "toItemDetails"
        case toWeb              = "toWeb"
        case toArticle          = "toArticle"
        case toDiscountVC       = "toDiscountVC"
        case toOrderDetailVC    = "toOrderDetailVC"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = SSTTimer()     // enable the timer
        
        collectionView.register(initNib("\(SSTHomeCategoryHeadView.classForCoder())"), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kCategoryHeadViewId)
        collectionView.register(initNib("\(SSTBlankHeaderView.classForCoder())"), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kBlankViewId)
        collectionView.register(initNib("\(SSTHomeDealsCell.classForCoder())"), forCellWithReuseIdentifier: kDealsCellId)
        collectionView.register(initNib("\(SSTHomeBannerCVCell.classForCoder())"), forCellWithReuseIdentifier: kBannerCellId)
        collectionView.register(initNib("\(SSTItemCVCell.classForCoder())"), forCellWithReuseIdentifier: kItemCellId)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        homeData.delegate = self
        discountInformation.delegate = self
        
        fetchHomeData()
        fetchData()
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = self.collectionView.setUpHeaderRefresh(refreshHeaderView) {
            self.fetchHomeData()
        }
    
        // when opened the home vc, then save the date viewed to user defaults, in order to see
        setUserDefautsData(kGuideDateLastViewed, value: Date().formatYYYYMM())
        setUserDefautsData(kGuideAppPrevVersion, value: kAppVersion)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.resendPaypalConfirmation()
        
        if self.messageView?.superview == nil {
            self.refreshMsgBarItem()
        } else {
            self.messageView?.upPullLoadData()
        }
    }
    
    @objc func viewRefreshWhenCartUpdated() {
        for cell in collectionView.visibleCells {
            if cell.isKind(of: SSTItemCVCell.classForCoder()) {
                if let itmV = (cell as? SSTItemCVCell)?.itemV {
                    itmV.setQtyTFAndButtons()
                }
            }
        }
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        self.messageView?.upPullLoadData()
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.messageView?.upPullLoadData()
    }

    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        for itm in validArray(homeData.newArrivals) {
            (itm as? SSTItem)?.promoCountdown = validInt64((itm as? SSTItem)?.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
        for itm in validArray(homeData.featureProducts) {
            (itm as? SSTItem)?.promoCountdown = validInt64((itm as? SSTItem)?.promoCountdown) - gFromLastEnterBackgroundToEnterForgroundSeconds
        }
        
        if gLatestApplicatonDidBecomeActiveDateYYYYMMDD != Date().formatYYYYMMDD() {
            fetchHomeData()
        }
        fetchData()
    }
    
    func refreshMsgBarItem() {
        messageData.fetchData() { data, error in
            if error == nil {
                if self.messageData.hasNew {
                    self.msgButton.setImage(UIImage(named: "home_message_reddot"), for: UIControlState.normal)
                } else {
                    self.msgButton.setImage(UIImage(named: "home_message"), for: UIControlState.normal)
                }
            }
        }
    }

    @IBAction func clickedMessageBarButton(_ sender: AnyObject) {
        if self.messageView == nil {
            self.messageView = loadNib("\(SSTHomeMessageView.classForCoder())") as? SSTHomeMessageView
            self.messageView?.frame =  CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenHeight)
            self.messageView?.alpha = 0.1
        }
        
        if messageView?.superview == nil {
            messageView?.messageData.fetchData()
            
            if let tmpMsgV = messageView {
                self.view.addSubview(tmpMsgV)
                tmpMsgV.show()
            }
            
            messageView?.itemClicked = { message in
                if let msg = message {
                    if msg.type >= 0 {
                        appDelegate.handleActionAfterReciveMsg(type: msg.type, value: validString(msg.value))
                    }
                }
            }
        } else {
            messageView?.clickedBgView(sender)
        }
    }
    
    func fetchHomeData() {
        if homeData.dataArray.count <= 0 {
            SSTProgressHUD.show(view: self.view)
        }
        homeData.fetchData()
    }
    
    override func fetchData() {
        checkAppVersion()
        SSTItemData.getStockNotifications()
        checkNotificationEnableEveryTwoWeeks()
        biz.dealMessage.getDealMessage()
        biz.guideData.fetchImages()
        gGlobalConfigs.fetchData()
        biz.cart.fetchData()
        
        if biz.user.isLogined {
            discountInformation.fetchData()
        }
    }
    
    func resendPaypalConfirmation() {
        var confirmations = validArray(FileOP.unarchive(kPaypalConfirmationFileName))
        if let mConfirmation = confirmations.first {
            biz.sendPaypalConfirmation(validNSDictionary(mConfirmation)) { (resp,err) -> Void in
                if err == nil { // have sent the confirmation to server successfully.
                    confirmations.removeFirst()
                    FileOP.archive(kPaypalConfirmationFileName, object: confirmations)
                }
            }
        }
    }
    
    func showInfomation() {     // pop the information view to customers one time one day
        let lastTimeString = validString(FileOP.unarchive(kHomePromoInfomationTimeFileName))
        let todayTimeString = Date().formatYYYYMMDD()
        if ( lastTimeString.isEmpty || lastTimeString != todayTimeString) && self.discountInformation.discountsForHomePopView.count > 0 {
            let showView = loadNib("\(SSTPromoInfomationView.classForCoder())") as! SSTPromoInfomationView
            showView.frame = self.view.bounds
            showView.discountInformation = self.discountInformation
            self.view.addSubview(showView)
            showView.itemClicked = { discount in
                if discount.isKind(of: SSTCategoryDiscount.self), let categoryDiscount = discount as? SSTCategoryDiscount {
                    self.categoryClicked = SSTCategory(groupId: validString(categoryDiscount.id), name: validString(categoryDiscount.title))
                    self.performSegue(withIdentifier: "\(SegueIdentifier.toSearchResult.rawValue)", sender: self)
                } else {
                    self.performSegue(withIdentifier: SegueIdentifier.toDiscountVC.rawValue, sender: self)
                }
            }
            FileOP.archive(kHomePromoInfomationTimeFileName, object: todayTimeString)
        }
    }
    
    fileprivate func checkAppVersion() {    // get the app version and pop the force upate view if need
        biz.getLastVersion { (data, error) in
            if error == nil {
                if let dict = data as? Dictionary<String,AnyObject> {
                    let forceUpdate = validInt(dict[kHomeForceUpdate]) == 1
                    let lastTimeString = validString(FileOP.unarchive(kHomeVersionTimeFileName))
                    let todayTimeString = Date().formatYYYYMMDD()
                    if validInt(kAppBuild) < validInt(dict["build"]) && ( forceUpdate || lastTimeString != todayTimeString ) {
                        let mAC = UIAlertController(title: kNewVersionUpdateTitle, message: (forceUpdate ? kNewVersionForceUpdateMsg : kNewVersionUpdateMsg), preferredStyle: .alert)
                        let laterAction = UIAlertAction(title: "Later", style: .default, handler: nil)
                        let updateAction = UIAlertAction(title: "Update", style: .default, handler: { action in
                            if let appStoreURL = URL(string: validString(dict["url"])) {
                                UIApplication.shared.openURL(appStoreURL)
                            }
                        })
                        if !forceUpdate {
                            mAC.addAction(laterAction)
                        }
                        mAC.addAction(updateAction)
                        self.present(mAC, animated: true, completion: nil)
                        FileOP.archive(kHomeVersionTimeFileName, object: todayTimeString)
                    }
                }
            }
        }
    }
    
    func checkNotificationEnableEveryTwoWeeks() {
        if gNotificationStatus == .On {
            return
        }
        
        if let notificationLastPromptDate = Date.fromString(validString(getUserDefautsData(kNotificationLastPromptDate))) {
            var needPopNotificationEnableView = true
            let today = Date()
            let afterTwoWeeksDate = notificationLastPromptDate.addingTimeInterval(60 * 60 * 24 * 14)
            if afterTwoWeeksDate.compare(today) == ComparisonResult.orderedDescending {
                needPopNotificationEnableView = false
            }
            
            if needPopNotificationEnableView {
                UserDefaults.standard.set("\(Date())", forKey: kNotificationLastPromptDate)
                
                let backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
                backgroundView.backgroundColor = UIColor.gray
                backgroundView.alpha = 0.3
                
                let notificationView = SSTNotificationView(frame: CGRect(x: 40*kProkScreenWidth, y:(kScreenHeight - 300*kProkScreenWidth)/2, width: kScreenWidth-40*kProkScreenWidth*2, height: 300*kProkScreenWidth))
                notificationView.notificationClick = { status, view in
                    if status == .show {
                        if let settingUrl = NSURL(string: UIApplicationOpenSettingsURLString) {
                            if UIApplication.shared.canOpenURL(settingUrl as URL) {
                                UIApplication.shared.openURL(settingUrl as URL)
                            }
                        }
                    }
                    backgroundView.removeFromSuperview()
                }
                
                UIApplication.shared.keyWindow?.addSubview(backgroundView)
                UIApplication.shared.keyWindow?.addSubview(notificationView)
            }
        } else { // app first launch after installing
            let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(notificationSettings)
            UIApplication.shared.registerForRemoteNotifications()
            UserDefaults.standard.set("\(Date())", forKey: kNotificationLastPromptDate)
        }
    }
    
    @objc func timerAlarm() {
        for ind in 0 ..< validInt(homeData.newArrivals?.count) {
            let item = homeData.newArrivals?.validObjectAtIndex(ind) as? SSTItem
            item?.minusOneToPromoCountdown()
        }
        for ind in 0 ..< validInt(homeData.featureProducts?.count) {
            let item = homeData.featureProducts?.validObjectAtIndex(ind) as? SSTItem
            item?.minusOneToPromoCountdown()
        }
        
        for cell in collectionView.visibleCells {
            if cell.isKind(of: SSTItemCVCell.classForCoder()) {
                (cell as? SSTItemCVCell)?.itemV.refreshCountdown()
            }
        }
    }
    
    func doAfterClickingSlideOrBanner(type: String, title: String, value: String) {
        switch type {
        case SlideInfoType.Search.rawValue:
            self.searchKey = value
            self.categoryClicked = nil
            self.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toSearchResult.rawValue, sender: nil)
        case SlideInfoType.Product.rawValue:
            SSTItem.fetchItemById(value) { data, error in
                if error == nil {
                    self.itemClicked = data as? SSTItem
                    self.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toItemDetail.rawValue, sender: nil)
                } else {
                    showToastOnlyForDEV("\(kErrorPrefixMsg) \(error!)")
                }
            }
        case SlideInfoType.Link.rawValue:
            self.webTitle = title
            self.webUrl = value
            self.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toWeb.rawValue, sender: nil)
        case SlideInfoType.Group.rawValue:
            self.categoryClicked = SSTCategory(groupId: value)
            self.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toSearchResult.rawValue, sender: nil)
        case SlideInfoType.Article.rawValue:
            self.articleId = value
            self.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toArticle.rawValue, sender: nil)
        case SlideInfoType.Message.rawValue:
            self.webTitle = title
            self.msgId = value
            self.performSegue(withIdentifier: SSTHomeVC.SegueIdentifier.toWeb.rawValue, sender: nil)
        default:
            break
        }
    }
}

// MARK: -- UITableViewDelegate

extension SSTHomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeData.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch validString(homeData.dataArray.validObjectAtIndex(section)) {
        case kHomeNewArrivals:
            return validInt(homeData.newArrivals?.count) - validInt(homeData.newArrivals?.count) % 2
        case kHomeFeaturedProducts:
            return validInt(homeData.featureProducts?.count) - validInt(homeData.featureProducts?.count) % 2
        default:
            return 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch validString(homeData.dataArray.validObjectAtIndex(indexPath.section)) {
        case kHomeSlides:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCell", for: indexPath)
            let slideView = loadNib("\(SSTSlideView.classForCoder())") as! SSTSlideView
            slideView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kHomeSlideHeight)
            slideView.setParas(validArray(homeData.slides).map({ $0 }), itemWidth: kScreenWidth, itemHeight: kHomeSlideHeight, placeholder: kIcon_slide)
            slideView.itemClick = { [weak self] item in
                if let slide = item as? SSTSlide {
                    self?.doAfterClickingSlideOrBanner(type: validString(slide.type), title: validString(slide.title), value: validString(slide.value))
                }
            }
            cell.addSubview(slideView)
            return cell
        case kHomeDailyDeals:
            let dealsCell = collectionView.dequeueReusableCell(withReuseIdentifier: kDealsCellId, for: indexPath) as! SSTHomeDealsCell
            dealsCell.items = validArray(homeData.dailyDeals) as! [SSTItem]
            dealsCell.itemClick = { [weak self] obj in
                if let dailyDeal = obj as? SSTItem {
                    self?.itemClicked = SSTItem(JSON: validDictionary(dailyDeal.toJSON()))
                    self?.performSegue(withIdentifier: SegueIdentifier.toItemDetail.rawValue, sender: self)
                }
            }
            dealsCell.seeAllClick = {
                self.tabBarController?.selectedIndex = TabIndexType.deal.rawValue
                if let nc = self.tabBarController?.selectedViewController {
                    let navigationController = nc as! UINavigationController
                    navigationController.popToRootViewController(animated: false)
                }
            }
            return dealsCell
        case kHomeBanners:
            let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kBannerCellId, for: indexPath) as! SSTHomeBannerCVCell
            bannerCell.banners = homeData.banners
            bannerCell.itemClick = { [weak self] item in
                if let banner = item as? SSTBanner {
                    self?.doAfterClickingSlideOrBanner(type: validString(banner.type), title: validString(banner.title), value: validString(banner.value))
                }
            }
            return bannerCell
        case kHomeNewArrivals, kHomeFeaturedProducts:
            let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: kItemCellId, for: indexPath) as! SSTItemCVCell
            itemCell.itemV.frame.size = kHomeCategoryCellSize
            let items = validString(homeData.dataArray.validObjectAtIndex(indexPath.section)) == kHomeNewArrivals ? homeData.newArrivals : homeData.featureProducts
            if let tItem = items?.validObjectAtIndex(indexPath.row) as? SSTItem {
                itemCell.item = tItem
            }
            return itemCell
        default:
            break
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch validString(homeData.dataArray.validObjectAtIndex(indexPath.section)) {
        case kHomeSlides:
            return CGSize(width: kScreenWidth, height: kHomeSlideHeight)
        case kHomeDailyDeals:
            return CGSize(width: kScreenWidth, height: kHomeDailyDealsCellHeight)
        case kHomeBanners:
            return CGSize(width: kScreenWidth, height: kHomeBannerCellHeight)
        case kHomeNewArrivals, kHomeFeaturedProducts:
            return kHomeCategoryCellSize
        default:
            return CGSize(width: 0, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch validString(homeData.dataArray.validObjectAtIndex(section)) {
        case kHomeNewArrivals, kHomeFeaturedProducts:
            return CGSize(width: kScreenWidth, height: 30)
        default:
            return CGSize(width: kScreenWidth, height: 0.1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch validString(homeData.dataArray.validObjectAtIndex(section)) {
        case kHomeNewArrivals, kHomeFeaturedProducts:
            return CGSize(width: kScreenWidth, height: 5)
        default:
            return CGSize(width: kScreenWidth, height: 0.1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            switch validString(homeData.dataArray.validObjectAtIndex(indexPath.section)) {
            case kHomeNewArrivals, kHomeFeaturedProducts:
                let hV = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kCategoryHeadViewId, for: indexPath) as! SSTHomeCategoryHeadView
                if validString(homeData.dataArray.validObjectAtIndex(indexPath.section)) == kHomeNewArrivals {
                    hV.setTitle(HomeSeeAllType.newArrival.rawValue)
                    hV.sellAllClick = {
                        self.homeSeeAll = HomeSeeAllType.newArrival
                        self.performSegue(withIdentifier: SegueIdentifier.toSeeAll.rawValue, sender: self)
                    }
                } else {
                    hV.setTitle(HomeSeeAllType.featureProducts.rawValue)
                    hV.sellAllClick = {
                        self.homeSeeAll = HomeSeeAllType.featureProducts
                        self.performSegue(withIdentifier: SegueIdentifier.toSeeAll.rawValue, sender: self)
                    }
                }
                return hV
            default:
                break
            }
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kBlankViewId, for: indexPath) as! SSTBlankHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch validString(homeData.dataArray.validObjectAtIndex(indexPath.section)) {
        case kHomeNewArrivals:
            if let tItem = homeData.newArrivals?.validObjectAtIndex(indexPath.row) as? SSTItem {
                self.itemClicked = tItem
                self.performSegue(withIdentifier: SegueIdentifier.toItemDetail.rawValue, sender: self)
            }
        case kHomeFeaturedProducts:
            if let tItem = homeData.featureProducts?.validObjectAtIndex(indexPath.row) as? SSTItem {
                self.itemClicked = tItem
                self.performSegue(withIdentifier: SegueIdentifier.toItemDetail.rawValue, sender: self)
            }
        default:
            break
        }
    }
}

// MARK: -- UIScrollViewDelegate

extension SSTHomeVC: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for cell in collectionView.visibleCells {
            if cell.isKind(of: SSTItemCVCell.classForCoder()) {
                if let itmV = (cell as? SSTItemCVCell)?.itemV {
                    if itmV.qtyTF.isFirstResponder {
                        itmV.qtyTF.resignFirstResponder()
                        return
                    }
                }
            }
        }
    }
}

// MARK: -- SSTUIRefreshDelegate

extension SSTHomeVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if (data as? SSTHomeData) != nil {
            collectionView.endHeaderRefreshing(.success, delay: 0.5)
            if let tmpData = data as? SSTHomeData {
                homeData = tmpData
                collectionView.reloadData()
            }
        } else if (data as? SSTDiscountInformation) != nil  {
            if data != nil {
                self.showInfomation()
            }
        } else {
            collectionView.endHeaderRefreshing(.failure, delay: 0.5)
        }
    }
}

// MARK: -- SegueHandlerType

extension SSTHomeVC: SegueHandlerType {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toItemDetail.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            destVC.item = itemClicked
            break
        case SegueIdentifier.toSearchResult.rawValue:
            let destVC = segue.destination as! SSTSearchResultVC
            if let keyword = searchKey {
                destVC.searchKey = keyword                  // from searchview or slide clicking
            } else {
                destVC.category = self.categoryClicked      // from slide clicking
            }
        case SegueIdentifier.toSeeAll.rawValue:
            let destVC = segue.destination as! SSTHomeSeeAllVC
            destVC.homeSeeAll = self.homeSeeAll
        case SegueIdentifier.toWeb.rawValue:
            let destVC = segue.destination as! SSTWebVC
            destVC.webTitle = self.webTitle
            destVC.webUrl = self.webUrl
            destVC.webHtmlString = self.webHtmlString
            destVC.msgId = msgId
        case SegueIdentifier.toOrderDetailVC.rawValue:
            let destVC = segue.destination as! SSTOrderDetailVC
            destVC.orderId = self.orderId
        case SegueIdentifier.toArticle.rawValue:
            let destVC = segue.destination as! SSTArticleVC
            destVC.articleId = self.articleId
        default:
            break
        }
    }
}
