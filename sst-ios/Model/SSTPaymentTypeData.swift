//
//  SSTPaymentTypeData.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/9.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let paymentTypesData = "data"

class SSTPaymentTypeData: BaseModel {
    
    var paymentTypes = [SSTPaymentType]()
    
    func update(_ array: Array<AnyObject>) {
        var mPaymentTypes = [SSTPaymentType]()
        for mOrder in array {
            if let paymentType = SSTPaymentType(JSON: validDictionary(mOrder)) {
                mPaymentTypes.append(paymentType)
            }
        }
        self.paymentTypes = mPaymentTypes
//        let COD_test = SSTPaymentType()
//        COD_test.paymentname = "C.O.D"
//        COD_test.paymentId = "5"
//        COD_test.CODType = 0
//        COD_test.isDisplay = false
//        COD_test.message = "C.O.D is Unvaliable"
//        COD_test.paymentlogo = "http://webdev05.sstparts.com:81/payment/5_d.png"
//        paymentTypes.append(COD_test)
    }
    
    func getPaymentType(_ countryCode: String, codOrderPrice: Double, shippingCompanyId: String, orderId: String, mergeTargetOrderPaymentId: Int? ) {
        biz.getPaymentType(countryCode, codOrderPrice: codOrderPrice ,shippingCompanyId: shippingCompanyId, orderId: orderId, mergeTargetOrderPaymentId: mergeTargetOrderPaymentId ) { (data, error) in
            if error == nil {
                self.update(validArray(data))
                self.delegate?.refreshUI(self)
            } else {
//                #if DEV
//                    let paymentType = SSTPaymentType()
//                    paymentType.isEnable = true
//                    paymentType.paymentId = "2"
//                    paymentType.paymentname = "PayPal"
//                    self.paymentTypes.append(paymentType)
//                    self.delegate?.refreshUI(self)
//                #endif
            }
        }
    }
    
    //获取欠款订单的支付方式
    func getBalancePaymentType() {
        biz.getRepayPaymentType { (data, error) in
            if error == nil {
                self.update(validArray(data))
                self.delegate?.refreshUI(self)
            } else {
//                #if DEV
//                    let paymentType = SSTPaymentType()
//                    paymentType.isEnable = true
//                    paymentType.paymentId = "2"
//                    paymentType.paymentname = "PayPal"
//                    self.paymentTypes.append(paymentType)
//                    self.delegate?.refreshUI(self)
//                #endif
                self.delegate?.refreshUI(error)
            }

        }
    }
}
