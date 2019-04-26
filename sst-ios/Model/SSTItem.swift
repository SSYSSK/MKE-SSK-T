//
//  SSTItem.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/14/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let KItemdailyDealsItem     = "dailyDealOrderItem"
let KItemNormalOrderItem    = "normalOrderItem"

let kItemId             = "productId"
let kItemSKU            = "productExtId"
let kItemName           = "productTitle"
let kItemPrice          = "outPrice"

let kItemThumbnail      = "thumbnail"
let kItemImages         = "imageList"
let kItemOriginImages   = "originImageList"
let kItemGroupId        = "groupId"
let kItemGroupTitle     = "groupTitle"
let kItemCarrierName    = "carrierName"
let kItemColor          = "color"
let kItemDateUpdated    = "updateDate"
let kItemStatus         = "productStatus"
let kItemWeight         = "weight"
let kItemCount          = "productCount"
let kItemShippingInfo   = "shippingInfo"
let kItemInStock        = "inStock"
let kItemAvailableQty   = "availableQty"
let kItemProductVo      = "productVo"

let kItemPromoStartDate     = "promoStartDate"
let kItemPromoMaxQtyPerUser = "promoMaxQtyPerUser"
let kItemPromoSelledQty     = "promoSelledQty"
let kItemPromoEndDate       = "promoEndDate"
let kItemPromoItemImg       = "promoItemImg"
let kItemPromoStartType     = "promoStartType"
let kItemPromotionId        = "promotionId"
let kItemPromoItemSort      = "promoItemSort"
let kItemPromoMaxQty        = "promoMaxQty"
let kItemPromoItemStatus    = "promoItemStatus"
let kItemPromoItemPrice     = "promoItemPrice"
let kItemPromoId            = "promoId"
let kItemPromoItemId        = "promoItemId"
let kItemPromoCountdown     = "promoCountDown"
let kItemProductVoPromoId   = "promotionId"

let kItemPromoItem          = "promoItem"

let kItemPromoUserCanBuyAtAll          = "qtyPromoUserCanBuyAtAll"
let kItemBrowseDate         = "browseTime"

let kItemFinalUnitPrice     = "finalUnitPrice"
let kItemShippingPromotions = "shippingPromotions"
let kItemProductDiscounts   = "productDiscounts"
let kItemMinimumQty         = "minimumQty"
let kItemDiscountPrice      = "price"
let kItemSavedMoney         = "yourSave"
let kSearchItemPrice        = "outPrice"
let kSearchItemImgs         = "productImgs"


let kOutPriceB              = "outPriceB"
let kOutPriceC              = "outPriceC"

let kPriceB              = "outPriceB"
let kPriceC              = "outPriceC"

let kItemPromoCountdownUnit: Int64 = 1000
let kIsFavorite             = "isFavorite"
let kItemProductBrowsingHistoryId = "productBrowsingHistoryId"

let kItemDailyDealImg       = "appImg"
let kItemFreeShippingInfos  = "freeShippingInfoVos"

class SSTItem: BaseModel {
    
    var id = String()
    var sku: String!
    var name: String!
    
    var outPrice: Double!
    
//    var outPriceBOrC: Double? // 用于ItemDetails
    
    var thumbnail: String = ""
    var imageList: [SSTItemImage]?
    var originImageList: [SSTItemImage]?
    var groupId: Int!
    var groupTitle: String!
    
    var dateUpdated: Date?
    
    var status: Int?
    var weight: Double?
    var count: Int?
    var shippingInfo: String?
    var availableQty: Int?
    
    var promoStartDate: Date?
    var promoEndDate: Date?
    var promoId: String? //如果是促销 ，就会有值
    var promoItemPrice: Double?
    var promoItemImg: String?
    var promoCountdown: Int64? // 剩余时间 一秒为单位
    var promoMaxQtyPerUser: Int? // 打折允许购买的最大数量
    var qtyPromoUserCanBuyAtAll: Int? //用户可以购买的数量
    
    var promoMaxQty: Int?
    var promoSelledQty: Int?
    
    var miniMumQty = 0 //数量
    var discountPrice = 0.0 //打折价格
    var savedMoney = 0.0 //省了多少钱
    var isFavorite: Bool?
    
    var shippingPromotions: [SSTShippingCompany]?
    var productDiscounts: [SSTProductDiscount] = [SSTProductDiscount]()
    var browsingHistoryId: String?
    var browseDate: Date?
    var isShowBrowseDate: Bool?
    
    var dailyDealImg: String?
    
    var freeShippingInfos: [SSTFreeShippingInfo]?
    
    var promoPrice: Double {
        get {
            return validDouble(promoItemPrice)
        }
    }
    
    var price: Double {
        get {
            if isPromoItem && validDouble(promoItemPrice) > kOneInMillion {
                return validDouble(promoItemPrice)
            } else {
                return outPrice
            }
        }
    }
    
    var listPrice: Double? {
        if validDouble(promoItemPrice) > kOneInMillion {
            return outPrice
        }
        return nil
    }
    
    var priceDiscountPercentTextItemDetail: String {
        get {
            var percentResult: Double = ( 1 - promoPrice / outPrice ) * 100
            if percentResult < kOneInMillion {
                return "0"
            } else if percentResult < 1 {
                percentResult = validDouble(validInt(percentResult * 10 + kOneInMillion)) / 10      // discard the point float
                return percentResult.formatCWithoutCurrency(f: ".1")
            } else {
                percentResult = validDouble(validInt(percentResult + kOneInMillion))                // discard the point float
                return percentResult.formatCWithoutCurrency(f: ".0")
            }
        }
    }
    
    var isPromoItem: Bool {
        get {
            if validInt64(promoCountdown) > 0 && promoId != nil && ( promoMaxQty == nil || validInt(promoSelledQty) < validInt(promoMaxQty) ) && outPrice - validDouble(promoItemPrice) > kOneInMillion {
                return true
            } else {
                return false
            }
        }
    }
    
    var promoCountdownText: String {
        get {
            if self.isPromoItem {
                return validInt64(self.promoCountdown).toCountdownText()
            } else {
                return ""
            }
        }
    }
    
    var inStock: Bool {
        get {
            if availableQty == nil || validInt(availableQty) > 0 {
                return true
            } else {
                return false
            }
        }
    }
    
    var isStockReminded: Bool {
        get {
            if !biz.stockRemindIds.isEmpty {
                //item在stockRemindId列表中并且缺货
                if biz.stockRemindIds[self.id] == true && self.inStock == false {
                    return true
                }
            }
            return false
        }
    }
    
    var isUnavailable: Bool {
        get {
            return status == 0
        }
    }
    
    var canAddToCart: Bool {
        get {
            return self.inStock && !self.isUnavailable
        }
    }
    
    var images: [String] {
        get {
            var rImgs = [String]()
            for img in validArray(self.imageList) {
                if let imgPath = (img as? SSTItemImage)?.path {
                    rImgs.append(imgPath)
                }
            }
            return rImgs
        }
    }
    
    var originImages: [String] {
        get {
            var rImgs = [String]()
            for img in validArray(self.originImageList) {
                if let imgPath = (img as? SSTItemImage)?.path {
                    rImgs.append(imgPath)
                }
            }
            return rImgs
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
        
        if map.JSON[kItemId] == nil && map.JSON[KItemdailyDealsItem] == nil &&  map.JSON[KItemNormalOrderItem] == nil && map.JSON[kOrderItemId] == nil && map.JSON[kItemProductVo] == nil {
            printDebug("Error: ItemId is empty. JSON: \(map.JSON)")
            return nil
        }
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        if let tId = map.JSON[kItemId] {
            if (tId as AnyObject).isKind(of: NSNumber.classForCoder()) {
                id <- (map[kItemId], transformIntToString)
            } else {
                id <- map[kItemId]
            }
        } else {
            id <- map[kItemId]
        }
        
        sku                 <- map[kItemSKU]
        name                <- map[kItemName]
        outPrice            <- map[kItemPrice]
        thumbnail           <- map[kItemThumbnail]
        groupId             <- map[kItemGroupId]
        groupTitle          <- map[kItemGroupTitle]
        dateUpdated         <- (map[kItemDateUpdated], transformStringToDate)
        status              <- map[kItemStatus]
        weight              <- map[kItemWeight]
        shippingInfo        <- map[kItemShippingInfo]
        count               <- map[kItemCount]
        isFavorite          <- map[kIsFavorite]
        availableQty        <- map[kItemAvailableQty]
//        outPriceBOrC        <- map[kOutPriceC]
        
        shippingPromotions  <- map[kItemShippingPromotions]
        productDiscounts    <- map[kItemProductDiscounts]
        browsingHistoryId   <- (map[kItemProductBrowsingHistoryId],transformIntToString)
        browseDate          <- (map[kItemBrowseDate],transformStringToDate)
        
        qtyPromoUserCanBuyAtAll <- map[kItemPromoUserCanBuyAtAll]
        
        promoId             <- map[kItemPromoId]
        promoItemPrice      <- map[kItemPromoItemPrice]
        promoStartDate      <- (map[kItemPromoStartDate], transformStringToDate)
        promoEndDate        <- (map[kItemPromoEndDate], transformStringToDate)
        promoItemImg        <- map[kItemPromoItemImg]
        promoCountdown      <- (map[kItemPromoCountdown], transformNSNumberToInt64)
        
        promoMaxQty         <- map["\(kItemPromoMaxQty)"]
        promoSelledQty      <- map["\(kItemPromoSelledQty)"]
        promoMaxQtyPerUser  <- (map["\(kItemPromoMaxQtyPerUser)"])
        
//        if let normalOrderItemDict = map[KItemNormalOrderItem].currentValue as? Dictionary<String, Any> {
//            self.setImages(validArray(normalOrderItemDict[kItemImages]))
//        }
//        self.setImages(validArray(map.JSON["\(kItemImages)"]))
        imageList           <- map["\(kItemImages)"]
        originImageList     <- map[kItemOriginImages]
        
        self.setProductDiscounts(validArray(map.JSON["\(kItemProductDiscounts)"]))
        self.setShippingPromotions(validArray(map.JSON["\(kItemShippingPromotions)"]))
        
        if !validDictionary(map.JSON[kItemPromoItem]).isEmpty {   // from home page API, deals page API, item detail page API
            promoItemPrice <- map["\(kItemPromoItem).\(kItemPromoItemPrice)"]
            promoStartDate <- (map["\(kItemPromoItem).\(kItemPromoStartDate)"], transformStringToDate)
            promoEndDate   <- (map["\(kItemPromoItem).\(kItemPromoEndDate)"], transformStringToDate)
            promoId        <- (map["\(kItemPromoItem).\(kItemPromoId)"],transformIntToString)
            promoItemPrice <- map["\(kItemPromoItem).\(kItemPromoItemPrice)"]
            promoItemImg   <- map["\(kItemPromoItem).\(kItemPromoItemImg)"]
            if !validDictionary(map.JSON[kItemPromoItem]).isEmpty {
                promoCountdown <- (map["\(kItemPromoItem).\(kItemPromoCountdown)"], transformNSNumberToInt64)
            }
            
            promoMaxQty    <- map["\(kItemPromoMaxQty)"]
            promoSelledQty <- map["\(kItemPromoSelledQty)"]
            promoMaxQtyPerUser <- (map["\(kItemPromoItem).\(kItemPromoMaxQtyPerUser)"])
            
            dailyDealImg        <- map["\(kItemPromoItem).\(kItemDailyDealImg)"]
        }
        
        if map.JSON.keys.contains(kCartQtyPrice) {
            outPrice   <- map[kCartQtyPrice]
            weight      <- map[kCartItemWeight]
        }
        
        if validString(map.JSON[kOrderItemId]) != "" || validString(map.JSON[kOrderId]) != "" {
            id          <- (map[kOrderItemProductId], transformIntToString)
            name        <- map[kOrderItemName]
            outPrice   <- map[kOrderItemPrice]
            weight      <- map[kOrderItemWeight]
            thumbnail   <- map[kOrderItemThumbnail]
        }
        
        if thumbnail == "" {
            thumbnail = validString(images.first)
        }
    
        if outPrice == nil {
            printDebug("WARN: SSTItem price is nil")
            outPrice = 0
        }
        
        if groupTitle == nil {
            groupTitle = ""
        }
        
        freeShippingInfos   <- map[kItemFreeShippingInfos]
    }
    
    func setDiscounts(_ arr: Array<Any>) {
        if arr.count > 0 {
            let discounts = validDictionary(arr[0])
            miniMumQty = validInt(discounts[kItemMinimumQty])
            discountPrice = validDouble(discounts[kItemDiscountPrice])
            savedMoney = validDouble(discounts[kItemSavedMoney])
        }
    }
    
    func setShippingPromotions(_ arr: Array<Any>) {
        var shippingPromotions = [SSTShippingCompany]()
        for  shippingPromotionDict in arr {
            
            if let shippingCompany = SSTShippingCompany(JSON: validDictionary(shippingPromotionDict)) {
                shippingPromotions.append(shippingCompany)
            }
        }
        self.shippingPromotions = shippingPromotions
    }
    
    func setProductDiscounts(_ arr: Array<Any>) {
        var productDiscounts = [SSTProductDiscount]()
        for  productDiscountDict in arr {
            if let productDiscount = SSTProductDiscount(JSON: validDictionary(productDiscountDict)) {
                productDiscounts.append(productDiscount)
            }
        }
        self.productDiscounts = productDiscounts
    }
    
    func update(_ data: Dictionary<String,AnyObject>) {
        mapping(map: Map(mappingType: .fromJSON, JSON: data))
    }
    
    static func fetchData(itemId: String, callback: RequestCallBack? = nil) {
        guard itemId != "" else {
            printDebug("ERROR: item id should not be empty when fetching item details")
            return
        }
        biz.getProductDetail(itemId) { (data, error) in
            if error == nil, let nItem = SSTItem(JSON: validDictionary(data)) {
                callback?(nItem, error)
            } else {
                callback?(nil, error)
            }
        }
    }
    
    static func addViewLog(_ itemId: String) {
        guard itemId != "" else {
            printDebug("ERROR: item id should not be empty when adding item view log")
            return
        }
        biz.addItemViewLog(itemId) { (data, error) in
        }
    }
    
    static func fetchDataAndViewLog(itemId: String, callback: RequestCallBack? = nil) {
        fetchData(itemId: itemId) { data, error in
            callback?(data, error)
        }
        addViewLog(itemId)
    }
    
    func minusOneToPromoCountdown() {
        if self.isPromoItem && validInt64(self.promoCountdown) > 0 {
            self.promoCountdown = validInt64(self.promoCountdown) - kItemPromoCountdownUnit
        }
    }
    
    static func fetchItemById(_ id: String, callback: @escaping RequestCallBack) {
        biz.getProductDetail(id) { (data, error) in
            if error == nil {
                if let item = SSTItem(JSON: validDictionary(data)) {
                    callback(item, nil)
                    return
                }
            }
            callback(nil, error)
        }
    }
    
    // MARK: -- item operations
    
    static func setQtyTFAndButtons(item: SSTItem, qtyTF: UITextField, minusButton: UIButton, addButton: UIButton, minQtyAvailable: Int = 0) {
        let qtyInCart = validInt(biz.cart.findItem(item.id)?.qty)
        
        if item.canAddToCart {
            qtyTF.isHidden = false
            minusButton.isHidden = false
            addButton.isHidden = false
        
            qtyTF.text = "\(qtyInCart)"
            qtyTF.textColor = qtyInCart > 0 ? RGBA(111, g: 115, b: 245, a: 1) : UIColor.black
            minusButton.setImage(UIImage(named: qtyInCart <= minQtyAvailable ? "icon_reduceNo" : "icon_reduce"), for: UIControlState.normal)
            addButton.setImage(UIImage(named: qtyInCart >= kCartItemMaxQty ? "icon_plusNo" : "icon_plus"), for: UIControlState.normal)
        } else {
            qtyTF.isHidden = true
            minusButton.isHidden = true
            addButton.isHidden = true
        }
    }
    
    static func updateQty(item: SSTItem, qtyTF: UITextField, minusButton: UIButton, addButton: UIButton, minQtyAvailable: Int = 0) {
        if biz.cart.isUpdating {
            if SSTProgressHUD.loadingView(view: minusButton.viewController()?.view) == nil {
                SSTToastView.showInfo(kCartIsUpdatingTip)
            }
            return
        }
        
        guard validString(qtyTF.text).isValidNaturalNumber else {
            qtyTF.text = validString(validInt(biz.cart.findItem(item.id)?.qty))
            return
        }
        guard validInt(qtyTF.text) >= minQtyAvailable else {
            qtyTF.text = validString(validInt(biz.cart.findItem(item.id)?.qty))
            return
        }
        if validInt(qtyTF.text) == validInt(biz.cart.findItem(item.id)?.qty) {
            return
        }
        
        let destQty = validInt(qtyTF.text)
        if let cartItem = biz.cart.findItem(item.id) {
            biz.cart.updateItem(cartItem, addingQty: destQty - cartItem.qty, callback: { (data, error) in
                SSTProgressHUD.dismiss(view: qtyTF.viewController()?.view)
                if minusButton.viewController()?.isKind(of: SSTCartVC.self) == false {
                    setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
                }
            })
        } else {
            biz.cart.addItem(item, addingQty: destQty, callback: { (data, error) in
                SSTProgressHUD.dismiss(view: qtyTF.viewController()?.view)
                if minusButton.viewController()?.isKind(of: SSTCartVC.self) == false {
                    setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
                }
            })
        }
    }
    
    static func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
        
        if toBeString.count > 1 && toBeString.sub(start: 0, end: 0) == "0" {
            toBeString = toBeString.sub(start: 1, end: 1)
            if toBeString.count == 1 {
                textField.text = ""
            } else {
                textField.text = toBeString.sub(start: 1, end: validInt(textField.text?.count) - 2)
            }
        }
        
        if toBeString.isNotEmpty && validBool(toBeString.isValidNaturalNumber) == false {
            return false
        }
        
        if validInt(toBeString) > kCartItemMaxQty {
            textField.text = validString(kCartItemMaxQty)
            return false
        }
        
        return true
    }
    
    static func textFieldDidEndEditing(item: SSTItem, qtyTF: UITextField, minusButton: UIButton, addButton: UIButton) {
        qtyTF.resignFirstResponder()
        updateQty(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
    
    static func clickedMinusButton(item: SSTItem, qtyTF: UITextField, minusButton: UIButton, addButton: UIButton, minQtyAvailable: Int = 0) {
        if biz.cart.isUpdating {
            if SSTProgressHUD.loadingView(view: minusButton.viewController()?.view) == nil {
                SSTToastView.showInfo(kCartIsUpdatingTip)
            }
            return
        } else if validInt(qtyTF.text) - 1 < minQtyAvailable {
            return
        }
        qtyTF.text = "\(validInt(qtyTF.text) - 1)"
        if let cartItem = biz.cart.findItem(item.id) {
            biz.cart.updateItem(cartItem, addingQty: -1) { data, error in
                SSTProgressHUD.dismiss(view: qtyTF.viewController()?.view)
                if minusButton.viewController()?.isKind(of: SSTCartVC.self) == false {
                    setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton, minQtyAvailable: minQtyAvailable)
                }
            }
        }
    }
    
    static func clickedAddButton(item: SSTItem, qtyTF: UITextField, minusButton: UIButton, addButton: UIButton, view: UIView? = nil,  block: (() -> Void)? = nil, afterAddingBlock: RequestCallBack? = nil ) {
        if biz.cart.isUpdating {
            if SSTProgressHUD.loadingView(view: minusButton.viewController()?.view) == nil {
                SSTToastView.showInfo(kCartIsUpdatingTip)
            }
            return
        } else if validInt(qtyTF.text) + 1 > kCartItemMaxQty {
            return
        }
        
        qtyTF.text = "\(validInt(qtyTF.text) + 1)"
        let oldItemQty = biz.cart.findItem(item.id)?.qty
        biz.cart.addItem(item) { data, error in
            SSTProgressHUD.dismiss(view: qtyTF.viewController()?.view)
            SSTProgressHUD.dismiss(view: view)
            if minusButton.viewController()?.isKind(of: SSTCartVC.self) == false {
                setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
            }
            if let itemUpdated = biz.cart.findItem(validString(item.id)) {  // show tip when cart quanity of item is greater than promo qty
                SSTCart.showPromoTip(itemUpdated: itemUpdated, oldItemQty: oldItemQty)
            }
            afterAddingBlock?(data, error)
        }
        
        block?()
    }
    
}

