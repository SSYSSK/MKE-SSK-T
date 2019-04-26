//
//  SSTFavorite.swift
//  sst-ios
//
//  Created by Amy on 16/9/13.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTFavoriteData: BaseModel {

    var items = [SSTItem]()
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func update(_ data: Array<Any>) {
        var mItms = [SSTItem]()
        for itmDict in validNSArray(data) {
            if let item = SSTItem(JSON: validDictionary(itmDict)) {
                if item.id.isNotEmpty {
                    mItms.append(item)
                }
            }
        }
        self.items = mItms
    }
    
    func addItem(_ item: SSTItem,callback:@escaping RequestCallBack) {
        self.items.append(item)
        biz.addItemToFavorite(item.id) { (data, error) in
            callback(data, error)
        }
    }
    
    func fetchData() {
        self.delegate?.refreshUI(self)
        biz.getFavorites() { [weak self] (data, error) in
            if error == nil {
                self?.update(validArray(data))
                self?.delegate?.refreshUI(self)
            }
        }
    }
    
    func removeItem(_ item: SSTItem, callback: @escaping RequestCallBack) {
        biz.deleteFavoriteItem(item.id) { [weak self] (data, error) in
            if error == nil {
                for index in 0 ..< validInt(self?.items.count) {
                    if item.id == self?.items[index].id {
                        self?.items.remove(at: index)
                        break
                    }
                }
                self?.delegate?.refreshUI(self)
            }
            callback(data, error)
        }
    }
}
