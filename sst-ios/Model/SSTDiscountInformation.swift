//
//  SSTDiscountInformation.swift
//  sst-ios
//
//  Created by 天星 on 17/3/20.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kDiscountCategoryVos           = "discountCategoryVos"
let kDiscountOrderVos              = "discountOrderVos"
let kTodayFreeShippingCompanies    = "todaysFreeShippingCompanies"

let kDiscountOrderTips             = "discountOrderTips"
let kDiscountCategoryTips          = "discountCategoryTipVos"
let kDiscountFreeShippingInfos     = "freeShippingInfoVos"

class SSTDiscountInformation: BaseModel {
    
    var orderDiscounts: [SSTOrderDiscount]?
    var categoryDiscounts: [SSTCategoryDiscount]?
    var todayFreeShippingCompanies: [SSTShippingCompany]?
    
    var orderTips: [String]?
    var categoryTips: [SSTCategoryDiscount]?
    var freeShippingInfos: [SSTFreeShippingInfo]?
    
    var isEmpty: Bool {
        get {
            if validInt(orderTips?.count) + validInt(categoryTips?.count) + validInt(freeShippingInfos?.count) == 0 {
                return true
            }
            return false
        }
    }
    
    var discountsForHomePopView: [Any] {
        get {
            var rDiscounts = [Any]()
            for ind in 0 ..< 2 {
                if let tmpDiscount = orderTips?.validObjectAtIndex(ind) {
                    rDiscounts.append(tmpDiscount)
                }
            }
            for ind in rDiscounts.count - 1 ..< 3 {
                if let tmpDiscount = categoryTips?.validObjectAtIndex(ind) {
                    rDiscounts.append(tmpDiscount)
                }
            }
            return rDiscounts
        }
    }
    
    func update(dictionary dict: NSDictionary) {
        var discounts = [SSTOrderDiscount]()
        for discountDict in validArray(dict[kDiscountOrderVos]) {
            if let tDiscount = SSTOrderDiscount(JSON: validDictionary(discountDict)) {
                discounts.append(tDiscount)
            }
        }
        self.orderDiscounts = discounts
        
        var categoryDiscounts = [SSTCategoryDiscount]()
        for discountDict in validArray(dict[kDiscountCategoryVos]) {
            if let tDiscount = SSTCategoryDiscount(JSON: validDictionary(discountDict)) {
                categoryDiscounts.append(tDiscount)
            }
        }
        self.categoryDiscounts = categoryDiscounts
        
        var todayFreeShippingCompanies = [SSTShippingCompany]()
        for companyDict in validArray(dict[kTodayFreeShippingCompanies]) {
            if let tCompany = SSTShippingCompany(JSON: validDictionary(companyDict)) {
                todayFreeShippingCompanies.append(tCompany)
            }
        }
        self.todayFreeShippingCompanies = todayFreeShippingCompanies
        
        var orderTips = [String]()
        for orderTip in validArray(dict[kDiscountOrderTips]) {
            orderTips.append(validString(orderTip))
        }
        self.orderTips = orderTips
        
        var categoryTips = [SSTCategoryDiscount]()
        for categoryTip in validArray(dict[kDiscountCategoryTips]) {
            if let tDiscount = SSTCategoryDiscount(JSON: validDictionary(categoryTip)) {
                categoryTips.append(tDiscount)
            }
        }
        self.categoryTips = categoryTips
        
        var freeShippingInfos = [SSTFreeShippingInfo]()
        for freeShippingInfo in validArray(dict[kDiscountFreeShippingInfos]) {
            if let tInfo = SSTFreeShippingInfo(JSON: validDictionary(freeShippingInfo)) {
                freeShippingInfos.append(tInfo)
            }
        }
        self.freeShippingInfos = freeShippingInfos
    }
    
    func fetchData() {
        biz.getDiscountInformation() { (data, error) in
            if error == nil && data != nil {
                self.update(dictionary: validNSDictionary(data))
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }

}
