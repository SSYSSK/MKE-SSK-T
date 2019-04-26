//
//  SSTHome.swift
//  sst-ios
//
//  Created by Amy on 16/5/19.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kHomeNews             = "news"

let kHomeSlides           = "slides"
let kHomeDailyDeals       = "dailyDeals"
let kHomeBanners          = "banners"
let kHomeNewArrivals      = "newArrivals"
let kHomeFeaturedProducts = "featuredProducts"

class SSTHomeData: BaseModel {
    
    var slides: [SSTSlide]?
    var dailyDeals: [SSTItem]?
    var banners: [SSTBanner]?
    var newArrivals: [SSTItem]?
    var featureProducts: [SSTItem]?
    
    var dataArray = [String]()
    
    override init() {
        super.init()
        
        if let dict = FileOP.unarchive(kHomeFileName) {
            self.update(dictionary: validDictionary(dict))
        }
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func update(dictionary dict: Dictionary<String, Any>) {
        
        var slideArray = [SSTSlide]()
        for slide in validArray(dict[kHomeSlides]) {
            if let tSlide = SSTSlide(JSON:validDictionary(slide)) {
                slideArray.append(tSlide)
            }
        }
        self.slides = slideArray
        
        var dailysArray = [SSTItem]()
        for daily in validArray(dict[kHomeDailyDeals]) {
            if let tDaily = SSTItem(JSON: validDictionary(daily)) {
                dailysArray.append(tDaily)
            }
        }
        self.dailyDeals = dailysArray
        
        var bannersArray = [SSTBanner]()
        for banner in validArray(dict[kHomeBanners]) {
            if let tBanner = SSTBanner(JSON: validDictionary(banner)) {
                bannersArray.append(tBanner)
            }
        }
        self.banners = bannersArray
        
        var newArrivals = [SSTItem]()
        for arrival in validArray(dict[kHomeNewArrivals]) {
            if let tArrival = SSTItem(JSON: validDictionary(arrival)) {
                newArrivals.append(tArrival)
            }
        }
        self.newArrivals = newArrivals
        
        var featureProducts = [SSTItem]()
        for featureProduct in validArray(dict[kHomeFeaturedProducts]) {
            if let tFeatureProduct = SSTItem(JSON: validDictionary(featureProduct)) {
                featureProducts.append(tFeatureProduct)
            }
        }
        self.featureProducts = featureProducts
        
        var tArray = [String]()
        if validInt(self.slides?.count) > 0 {
            tArray.append(kHomeSlides)
        }
        if validInt(self.dailyDeals?.count) > 0 {
            tArray.append(kHomeDailyDeals)
        }
        if validInt(self.banners?.count) > 1 {
            tArray.append(kHomeBanners)
        }
        if validInt(self.newArrivals?.count) > 1 {
            tArray.append(kHomeNewArrivals)
        }
        if validInt(self.featureProducts?.count) > 1 {
            tArray.append(kHomeFeaturedProducts)
        }
        self.dataArray = tArray
    }
    
    func fetchData() {
        biz.getHomePage() { (data, error) in
            if error == nil && data != nil {
                self.update(dictionary: validDictionary(data))
                FileOP.archive(kHomeFileName, object: validDictionary(data))
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }
    
    func getDiscountInformation() {
        biz.getDiscountInformation { (data, error) in
            if error == nil && data != nil {
                printDebug("data====\(validString(data))")
            }
        }
    }
    
}
