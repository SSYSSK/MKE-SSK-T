//
//  SSTBestSelling.swift
//  sst-ios
//
//  Created by Amy on 16/8/9.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kCartBestSelling = "bestSelling"
let kCartMostPopular = "popularToday"

class SSTBestSelling: BaseModel {

    fileprivate(set) var itemsDict = Dictionary<String,[SSTItem]>()
    
    func update(dictionary dict: NSDictionary) {
        
        if dict[kCartBestSelling] != nil {
            var bestSelling = [SSTItem]()
            for item in validArray(dict[kCartBestSelling]) {
                if let kItem = SSTItem(JSON: validDictionary(item)) {
                    bestSelling.append(kItem)
                }
            }
            itemsDict[kCartBestSelling] = bestSelling
        }
        
        if dict[kCartMostPopular] != nil {
            var mostPopular = [SSTItem]()
            for item in validArray(dict[kCartMostPopular]) {
                if let kItem = SSTItem(JSON: validDictionary(item)) {
                    mostPopular.append(kItem)
                }
            }
            itemsDict[kCartMostPopular] = mostPopular
        }
    }
    
    func fetchData() {
        fetchDataCartBestSellings()
        fetchDataMostPopular()
    }
    
    func fetchDataCartBestSellings() {
        biz.getCartBestSellings { (data, error) in
            if error == nil {
                self.update(dictionary: validNSDictionary(data))
                self.delegate?.refreshUI(self)
            } else {
//                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func fetchDataMostPopular() {
        biz.getMostPopular { (data, error) in
            if error == nil {
                self.update(dictionary: validNSDictionary(data))
                self.delegate?.refreshUI(self)
            } else {
//                SSTToastView.showError(validString(error))
            }
        }
    }
}
