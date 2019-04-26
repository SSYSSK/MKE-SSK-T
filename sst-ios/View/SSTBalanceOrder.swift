//
//  SSTBalanceOrder.swift
//  sst-ios
//
//  Created by Amy on 2017/4/20.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kMandatoryOrder = "mandatoryAmountDueOrders"
let kCODOrder = "codAmountDueOrders"
let kShipFirstOrder = "shipFirstPayLaterAmountDueOrders"

let kAmountDueOrder = "amountDueOrders"
let kAllAmountDue = "allAmountDue"

class SSTBalanceOrder {
    var orders = [SSTOrder]()
    var allAmountDue: Double?
}

class SSTBalanceOrderData: BaseModel {
    
    var mandatoryOrders = SSTBalanceOrder()
    var codOrders = SSTBalanceOrder()
    var shipOrders = SSTBalanceOrder()
    
    var hasBalanceOrder: Bool { //是否有欠款订单
        get {
            if mandatoryOrders.orders.count == 0 && codOrders.orders.count == 0 && shipOrders.orders.count == 0 {
                return false
            }
            return true
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    //获取用户的欠款订单
    func getDueOrders() {
        biz.getAmountDueOrders { (data, error) in
            if nil == error, let tmpData = data {
                //cod order
                let codDict = validDictionary(validDictionary(tmpData)[kCODOrder])
                let codOrderArr = validArray(codDict[kAmountDueOrder])
                let tmpCODOrders = SSTBalanceOrder()
                for tmpOrder in codOrderArr {
                    if let order = SSTOrder(JSON: validDictionary(tmpOrder)) {
                        tmpCODOrders.orders.append(order)
                    }
                }
                tmpCODOrders.allAmountDue = validDouble(codDict[kAllAmountDue])
                self.codOrders = tmpCODOrders
                
                //mandatory order
                let mandatoryDict = validDictionary(validDictionary(tmpData)[kMandatoryOrder])
                let mandatoryOrderArr = validArray(mandatoryDict[kAmountDueOrder])
                let tmpMandatoryOrders = SSTBalanceOrder()
                for tmpOrder in mandatoryOrderArr {
                    if let order = SSTOrder(JSON: validDictionary(tmpOrder)) {
                        tmpMandatoryOrders.orders.append(order)
                    }
                }
                tmpMandatoryOrders.allAmountDue = validDouble(mandatoryDict[kAllAmountDue])
                self.mandatoryOrders = tmpMandatoryOrders

                //shipFirst order
                let shipFirstDict = validDictionary(validDictionary(tmpData)[kShipFirstOrder])
                let shipFirstOrderArr = validArray(shipFirstDict[kAmountDueOrder])
                let tmpShipFirstOrders = SSTBalanceOrder()
                for tmpOrder in shipFirstOrderArr {
                    if let order = SSTOrder(JSON: validDictionary(tmpOrder)) {
                        tmpShipFirstOrders.orders.append(order)
                    }
                }
                tmpShipFirstOrders.allAmountDue = validDouble(shipFirstDict[kAllAmountDue])
                self.shipOrders = tmpShipFirstOrders
                self.delegate?.refreshUI(self)
            }
        }
    }
}
