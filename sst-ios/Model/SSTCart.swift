//
//  SSTCart.swift
//  sst-ios
//
//  Created by Amy on 16/5/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kCartTotalPrice     = "orderTotal"
let kCartItems          = "items"
let kCartTotal          = "total"

let kCartOrderItemsTotal            = "orderItemsTotal"
let kComplexOrderVo                 = "complexOrderVo"
let kCurrentLevelDiscountTip        = "currentLevelDiscountTip"
let kNextLevelDiscountTips          = "nextLevelDiscountTips"
let kTodaysFreeShippingCompanyTips  = "todaysFreeShippingCompanyTips"

let kCartDelay = 0.3

let kCartItemMaxQty = 9999

protocol SSTCartBadgeValueDelegate: class {
    func refreshUI()
}

class SSTCart: BaseModel {
    
    var items = [SSTCartItem]()
    
    var orderTotal = 0.0               //购物车原总价（不包含税和物流）
    var orderItemsTotal = 0.0          //商品应付价格（最终价格）
    var badgeValueDelegate: SSTCartBadgeValueDelegate?
    
    var addItemsTask: AsynTask?
    var updateItemsTask: AsynTask?
    
    var currentLevelDiscountTip:String?
    var nextLevelDiscountTips:Array<Any>?
    var todaysFreeShippingCompanyTips:Array<Any>?
    
    var isUpdating = false
    
    var qty: Int {
        get {
            var count = 0
            for item in self.items {
                count += item.qty
            }
            return count
        }
    }
    
    var totalChecked: Double {
        get {
            var total = 0.0
            for item in itemsChecked {
                total += item.price * Double(item.qty)
            }
            return total
        }
    }
    
    var totalOriginPrice: Double {
        get {
            var total = 0.0
            for item in self.items {
                //TOOD  这里有 bug，price会出现空的情况, 具体原因待查
                if let listPrice = item.listPrice{
                    total += validDouble(listPrice) * Double(item.qty)
                }
            }
            return total
        }
    }
    
    var itemIds: [String] {
        get {
            var tmpItemIds = [String]()
            for item in self.items {
                tmpItemIds.append(item.itemId)
            }
            return tmpItemIds
        }
    }
    
    var weight: Double {
        get {
            var tWeight: Double = 0
            for item in self.itemsChecked {
                tWeight += validDouble(item.qty) * validDouble(item.weight)
            }
            return tWeight
        }
    }
    
    var tipsOfOrderDiscountAndFreeShippingCompany: [String] {
        get {
            var rStrings = [String]()
            for ind in 0 ..< validInt(self.nextLevelDiscountTips?.count) {
                rStrings.append(validString(self.nextLevelDiscountTips?.validObjectAtIndex(ind)))
            }
            if rStrings.count <= 0 {
                for ind in 0 ..< validInt(self.todaysFreeShippingCompanyTips?.count) {
                    rStrings.append(validString(self.todaysFreeShippingCompanyTips?.validObjectAtIndex(ind)))
                }
            }
            return rStrings
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func findItem(_ itemId: String) -> SSTCartItem? {
        var rItem: SSTCartItem?
        
        for mItem in self.items {
            if itemId == mItem.id {
                rItem = mItem
                break
            }
        }
        return rItem
    }
    
    static func showPromoTip(itemUpdated: SSTCartItem, oldItemQty: Int?) {
        if itemUpdated.isPromoItem {
            if itemUpdated.promoQty > 0 && itemUpdated.qty > itemUpdated.promoQty && validInt(oldItemQty) <= itemUpdated.promoQty {
                if itemUpdated.boughtPromoQty == 0 {
                    SSTToastView.showInfo(String(format: kItemDailyDealsText1, validDouble(itemUpdated.promoPrice).formatC(), validInt(itemUpdated.promoCountContained), validInt(itemUpdated.promoCountContained) == 1 ? "" : "s", itemUpdated.outPrice.formatC()))
                } else if itemUpdated.boughtPromoQty > 0 {
                    SSTToastView.showInfo(String(format: kItemDailyDealsText2, validDouble(itemUpdated.promoPrice).formatC(), validInt(itemUpdated.promoCountContained), validInt(itemUpdated.promoCountContained) == 1 ? "" : "s", itemUpdated.outPrice.formatC(), itemUpdated.boughtPromoQty))
                }
            } else if itemUpdated.promoQty == 0 && itemUpdated.boughtPromoQty > 0 && validInt(oldItemQty) == 0 {
                SSTToastView.showInfo(kItemDailyDealsText3)
            }
        }
    }
    
    func addItem(_ item: SSTItem, addingQty: Int = 1, callback: RequestCallBack? = nil) {
        self.addItems([item], addingQtys: [addingQty]) { (data, error) in
            callback?(data, error)
        }
    }
    
    func addItems(_ items: [SSTItem], addingQtys: [Int], callback: RequestCallBack? = nil) {
        
        if biz.cart.isUpdating {
//            SSTToastView.showError(kOperationTooFastTip)
            return
        }
        
        let itemsTmp = self.items
        
        for ind in 0 ..< items.count {
            if let tItem = findItem(items[ind].id) {
                tItem.addingQty = tItem.addingQty + addingQtys[ind]
            } else {
                if let tItem = SSTCartItem(JSON: items[ind].toJSON()) {
                    tItem.addingQty = addingQtys[ind]
                    self.items.append(tItem)
                }
            }
        }
        
        TaskUtil.cancel(addItemsTask)
        addItemsTask = TaskUtil.delayExecuting(kCartDelay) { [weak self] in
            var addingItems = [SSTCartItem]()
            var addingQtys = [Int]()
            for item in validArray(self?.items) as! [SSTCartItem] {
                if item.addingQty > 0 {
                    addingItems.append(item)
                    addingQtys.append(item.addingQty)
                }
            }
            
            guard addingItems.count > 0 else {
                return
            }
            
            self?.isUpdating = true
            SSTProgressHUD.show(view: getTopVC()?.view)
            biz.addCartItems(addingItems, qtys: addingQtys) { [weak self] (data, error) in
                if error == nil {
                    self?.update(validDictionary(data))
                    FileOP.archive(kCartFileName, object: validDictionary(data))
                    self?.refreshUI(self)
                    self?.popToRootVC()
                } else {
                    self?.items = itemsTmp
                    self?.refreshUI(error)
                }
                callback?(data, error)
                self?.isUpdating = false
            }
        }
    }
    
    func updateItem(_ item: SSTCartItem, addingQty: Int, callback: RequestCallBack? = nil) {
        updateItems(itms: [item], addingQtys: [addingQty]) { (data, error) in
            callback?(data, error)
        }
    }
    
    func updateItems(itms: [SSTCartItem], addingQtys: [Int], callback: RequestCallBack? = nil) {
        if biz.cart.isUpdating {
//            SSTToastView.showError(kOperationTooFastTip)
            return
        }
        
        for ind in 0 ..< itms.count {
            if let foundItem = findItem(itms[ind].id) {
                foundItem.addingQty = foundItem.addingQty + addingQtys[ind]
            }
        }
        
        TaskUtil.cancel(updateItemsTask)
        updateItemsTask = TaskUtil.delayExecuting(kCartDelay) { [weak self] in
            self?.isUpdating = true
            SSTProgressHUD.show(view: getTopVC()?.view)
            biz.updateCartItems(itms) { [weak self] (data, error) in
                if error == nil {
                    self?.update(validDictionary(data))
                    FileOP.archive(kCartFileName, object: validDictionary(data))
                    self?.refreshUI(self)
                    self?.popToRootVC()
                } else {
                    SSTToastView.showError("Fail to update item quantity")
                    self?.refreshUI(error)
                }
                callback?(data, error)
                self?.isUpdating = false
            }
        }
    }
    
    func removeItems(_ items: [SSTItem]) {
        var ids = [String]()
        for item in items {
            ids.append(item.id)
        }
        removeItems(ids)
    }
    
    func removeItems(_ itemIds: [String], callback: RequestCallBack? = nil) {
        if biz.cart.isUpdating {
//            SSTToastView.showError(kOperationTooFastTip)
            return
        }
        
        self.isUpdating = true
        SSTProgressHUD.show(view: getTopVC()?.view)
        biz.removeCartItems(itemIds) { [weak self] (data, error) in
            if error == nil {
                self?.update(validDictionary(data))
            } else {
                printDebug(error.debugDescription)
                #if DEV
                    for index in 0 ..< itemIds.count {
                        for jnd in 0 ..< validInt(self?.items.count) {
                            if itemIds[index] == self?.items[jnd].id  {
                                self?.items.remove(at: jnd)
                                break
                            }
                        }
                    }
                #endif
            }
            callback?(data, error)
            self?.refreshUI(self)
            self?.isUpdating = false
        }
    }
    
    var itemsChecked: [SSTCartItem]! {
        get {
            var rItems = Array<SSTCartItem>()
            for item in items {
                if item.checked {
                    rItems.append(item)
                }
            }
            return rItems
        }
    }
    
    func popToRootVC() {
        if let topVC = getTopVC() {
            if topVC.isKind(of: SSTCartVC.classForCoder()) {
                return
            }
            if let firstVC = topVC.navigationController?.childViewControllers.first {
                if topVC.isKind(of: SSTItemDetailVC.classForCoder()) && firstVC.isKind(of: SSTCartVC.classForCoder()) {
                    return
                }
                if topVC.isKind(of: SSTOrderConfirmVC.classForCoder()) && firstVC.isKind(of: SSTCartVC.classForCoder()) {
                    return
                }
                if topVC.isKind(of: SSTWarehouseItemsVC.classForCoder()) && firstVC.isKind(of: SSTCartVC.classForCoder()) {
                    return
                }
            }
            for nc in validArray(topVC.tabBarController?.childViewControllers) {
                if let firstVC = (nc as? UINavigationController)?.childViewControllers.first {
                    if firstVC.isKind(of: SSTCartVC.classForCoder()) {
                        firstVC.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
        }
    }
    
    @objc func refreshViewWhenCartUpdated() {
        if let childControllers = gMainTC?.childViewControllers as? [UINavigationController] {
            for nc in childControllers {
                for vc in nc.childViewControllers {
                    if vc.responds(to: #selector(SSTHomeVC.viewRefreshWhenCartUpdated)) {
                        vc.perform(#selector(SSTHomeVC.viewRefreshWhenCartUpdated))
                    }
                }
            }
        }
    }
    
    func refreshUI(_ data: Any?) {
        self.badgeValueDelegate?.refreshUI()
        self.delegate?.refreshUI(data)
        self.refreshViewWhenCartUpdated()
    }
    
    func update(_ dict: Dictionary<String,AnyObject>) {
        var items = [SSTCartItem]()
        let dictvo = validDictionary(dict[kComplexOrderVo])
        
        for itmDict in validArray(dictvo[kCartItems]) {
            if let item = SSTCartItem(JSON: validDictionary(itmDict)) {
                if item.id.isNotEmpty {
                    items.append(item)
                }
            }
        }
        
        self.items = items
        self.orderTotal = validDouble(dictvo[kCartTotalPrice])
        self.orderItemsTotal = validDouble(dictvo[kCartOrderItemsTotal])
        
        self.currentLevelDiscountTip = validString(dict[kCurrentLevelDiscountTip])
        self.nextLevelDiscountTips = validArray(dict[kNextLevelDiscountTips])
        self.todaysFreeShippingCompanyTips =  validArray(dict[kTodaysFreeShippingCompanyTips])
    }
    
    func fetchData() {
        biz.getCartItems() { [weak self] (data, error) in
            if error == nil {
                self?.update(validDictionary(data))
                FileOP.archive(kCartFileName, object: validDictionary(data))
                self?.refreshUI(self)
            } else {
                self?.refreshUI(error)
            }
        }
    }
    
//    static func fetchShippingInfoBeforePlacingOrder(itemsId: [String], itemsTotal: Double, _ callback: @escaping RequestCallBack) {
//        biz.getCartShippingDetail(itemsId: itemsId,itemsTotal: itemsTotal) { data, error in
//            callback(data, error)
//        }
//    }
    
    //获取shipping Info信息，包括多仓库的时候
    static func fetchShippingInfoBeforePlacingOrder(itemsId: [String], shippingAddressId: String, _ callback: @escaping RequestCallBack) {
        biz.getCartShippingDetailInfo(itemsId: itemsId, shippingAddressId: shippingAddressId) { (data, error) in
            callback(data, error)
        }
        
    }
    
    static func fetchLastmergableOrder(_ shippingAddressId: String, itemsId: [String], itemsTotal: Double,callback: @escaping RequestCallBack) {
        biz.getLastMergableOrder(shippingAddressId,itemsId: itemsId,itemsTotal: itemsTotal) { (data, error) in
            callback(data, error)
        }
    }
    
}


