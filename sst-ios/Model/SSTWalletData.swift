//
//  SSTWalletData.swift
//  sst-ios
//
//  Created by Amy on 2017/3/22.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kwalletDetail      = "walletDetails"
let kWalletTotalAmount = "totalAmount"

class SSTWalletData: BaseModel {
    
    var totalAmount: Double?
    var items = [SSTWallet]()

    func update(_ data: Array<Any>) {
        var mItms = [SSTWallet]()
        for itemDict in validNSArray(data) {
            if let tmpItem = SSTWallet(JSON: validDictionary(itemDict)) {
                mItms.append(tmpItem)
            }
        }
        self.items.append(contentsOf: mItms)
    }
    
    func getWalletDetailInfo(pageNum: Int) {
        if pageNum == 1 {
            self.items.removeAll()
        }
        biz.getWalletDetailInfo(pageNum: pageNum) { (data, error) in
            if nil == error {
                let dic = validDictionary(data)
                self.totalAmount = validDouble(dic[kWalletTotalAmount])
                self.update(validArray(dic[kwalletDetail]))
                self.delegate?.refreshUI(self)
            }
        }
    }

    func getWalletBalance() {
        biz.getWalletBalance { (data, error) in
            if nil == error {
                let dic = validDictionary(data)
                self.totalAmount = validDouble(dic[kWalletTotalAmount])
                self.delegate?.refreshUI(self)
            }
        }
    }
}
