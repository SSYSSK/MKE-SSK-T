//
//  SSTOrderPayCardInfoCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/30.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTOrderPayCardInfoCell: SSTBaseCell {

    @IBOutlet weak var cardIcon: UIButton!
    @IBOutlet weak var CODButton: UIButton!
    @IBOutlet weak var total: UILabel!
    
    var clickToCODBlock:(() -> Void)?
    var clickPaymentTypeBlock:(( _ paymentAmount: Double) -> Void)?
    var paymentType = SSTPaymentType()
    var walletTotal: Double = 0.0  //当输入框的金额大于支付方式的金额，选中的支付方式金额为 输入框金额 - 支付方式金额
                    // 当输入框的金额小于当前选中的金额（由于切换支付方式造成的场景），则输入框的金额变成支付方式的实际金额，当前选择的支付方式对应的金额为0
    func setData(paymentType: SSTPaymentType, walletAmount: Double, selectedPaymentId: Int) {
        self.paymentType = paymentType
        walletTotal = walletAmount
        if let url = URL(string: paymentType.paymentlogo) {
            cardIcon.af_setImage(for: .normal, url: url)
        }
        
        var tAmount = paymentType.orderPaymentTotal - walletAmount
        if tAmount < kOneInMillion {
            tAmount = 0.00
        }
        
        total.text = tAmount.formatC()
        
        
        if validInt(paymentType.paymentId) == SSTPaymentMethod.cod_SELECTED.rawValue - 50 {
            if paymentType.isEnable == false {//表示在COD模式下，COD不可用，
                if paymentType.CODType == 0 { //并且用户没有申请COD，则显示apply button
                    CODButton.isHidden = false
                    total.isHidden = !CODButton.isHidden
                } else {
                    CODButton.isHidden = true
                    total.isHidden = !CODButton.isHidden
                }
            } else { //COD 可用
                CODButton.isHidden = true
                total.isHidden = !CODButton.isHidden
                if validInt(paymentType.paymentId) == selectedPaymentId {
                    cardIcon.backgroundColor = kPurpleBgClolor
                    total.textColor = UIColor.black
                } else {
                    cardIcon.backgroundColor = UIColor.white
                    total.textColor = kDarkGaryColor
                }
            }
            
        } else {
            if validInt(paymentType.paymentId) == selectedPaymentId {
                cardIcon.backgroundColor = kPurpleBgClolor
                total.textColor = UIColor.black
            } else {
                cardIcon.backgroundColor = UIColor.white
                total.textColor = kDarkGaryColor
            }
            CODButton.isHidden = true
        }
        
    }

    @IBAction func clickedPaymentAction(_ sender: AnyObject) {
        if validInt(paymentType.paymentId) == 5 && paymentType.isEnable == false {
            return
        }
        
        if let block = clickPaymentTypeBlock {
            if paymentType.orderPaymentTotal <= walletTotal {
                walletTotal = paymentType.orderPaymentTotal
            }
            block(walletTotal)
        }

    }
    
    @IBAction func clickedCODAction(_ sender: AnyObject) {
        if let block = clickToCODBlock {
            block()
        }
    }
    
}
