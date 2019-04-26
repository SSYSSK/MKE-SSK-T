//
//  SSTHotProductData.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let hotProductData       = "data"

class SSTHotProductData: BaseModel {
    
    var hotProducts = [SSTHotProduct]()
    var advertisingProducts = [SSTHotProduct]()
    
    func getHotProducts(array: NSArray) -> [SSTHotProduct] {
        var hotProducts = [SSTHotProduct]()
        for itemDict in array {
            if let hotProduct = SSTHotProduct(JSON: validDictionary(itemDict)) {
                hotProducts.append(hotProduct)
            }
        }
        return hotProducts
    }
    
    func update(data: Any?, error: Any?) {
        if error == nil {
            self.hotProducts = self.getHotProducts(array: validNSArray(data))
            self.delegate?.refreshUI(self)
        } else {
//            SSTToastView.showError(validString(error))
        }
    }
    
    func getHotProductsInBrand(_ brandId:Int) {
        biz.getHotProductsInBrand(brandId) { (data, error) in
            self.update(data: data, error: error)
        }
    }
   
    func getHotProductsInCategory(_ groupId:Int) {
        biz.getHotProductsInCategory(groupId) { (data, error) in
            self.update(data: data, error: error)
        }
    }
    
    func getHotProductsInSeries(_ seriesId:Int) {
        biz.getHotProductsInSeries(seriesId) { (data, error) in
            self.update(data: data, error: error)
        }
    }
    
    func getAdvertisingProducts() {
        biz.getAdvertisingProducts() { (data, error) in
            if error == nil {
                self.advertisingProducts = self.getHotProducts(array: validNSArray(data))
                self.delegate?.refreshUI(self)
            } else {
//                SSTToastView.showError(validString(error))
            }
        }
    }
}
