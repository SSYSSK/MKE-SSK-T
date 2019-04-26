//
//  SSTBalancePayView.swift
//  sst-ios
//
//  Created by Amy on 2017/4/25.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTBalancePayView: UIView {

    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var walletChooseImg: UIImageView!
    @IBOutlet weak var walletTotal: UILabel!
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var walletAmount: UITextField!
    @IBOutlet weak var paypalAmount: UILabel!
    @IBOutlet weak var payAmount: UILabel!
    @IBOutlet weak var paypalIcon: UIImageView!
    @IBOutlet weak var walletViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paypalBtn: UIButton!
    
    var isSelectWallet = false
    var wallet = 0.0  //当前用户的钱包余额
    var totalToPay = 0.0 //总共需要支付的金额
    var paypalToPay = 0.0  //paypal需要支付的金额
    var isSelectPaypal = true
    
    var combinePayBlock:(() ->Void)?
    
    func setData(paymentData: SSTPaymentTypeData, totalToPay: Double, wallet: Double, orderIds:[String]) {
        
        self.totalToPay = totalToPay
        self.wallet = wallet
        walletView.isHidden = !isSelectWallet
        self.paypalAmount.text = totalToPay.formatC()
        if validDouble(wallet) > kOneInMillion {
            walletViewHeightConstraint.constant = 50
            walletTotal.text = "My Wallet (\(validString(wallet.formatC())))"
        } else {
            walletViewHeightConstraint.constant = 0
        }
        if orderIds.count > 1 {
            orderNumber.text = "Order Number: Combined"
        } else {
            orderNumber.text = "Order Number: \(validString(orderIds.first))"
        }
        self.payAmount.text = totalToPay.formatC()
        
    }
    
    //选择钱包事件
    @IBAction func clickedWalletAction(_ sender: AnyObject) {
        isSelectWallet = !isSelectWallet
        walletView.isHidden = !isSelectWallet
        if isSelectWallet == true {
            walletChooseImg.image = UIImage(named: kCheckboxSelectedImgName)
            if validDouble(walletAmount.text) > kOneInMillion {
                paypalToPay = totalToPay - validDouble(walletAmount.text)
                paypalAmount.text = paypalToPay.formatC()
            }
        } else {
            walletChooseImg.image = UIImage(named: kCheckboxNormalImgName)
            //不使用钱包支付，paypal显示原来需要支付的金额
            paypalToPay = totalToPay
            paypalAmount.text = totalToPay.formatC()

        }

        if validDouble(walletAmount.text) - validDouble(paypalToPay) > kOneInMillion { //paypal 需要支付的金额大于0，则paypal处于可用状态
            isSelectPaypal = !isSelectPaypal
        }
        if isSelectPaypal == true {
            paypalIcon.image = UIImage(named: "icon_paypal_sel")
        } else {
            paypalIcon.image = UIImage(named: "icon_paypal_unsel")
        }
    }
    
    @IBAction func clickedDeleteAction(_ sender: AnyObject) {
        self.removeFromSuperview()
    }
    
    @IBAction func clickedPayAction(_ sender: AnyObject) {
        if let block = combinePayBlock {
            block()
        }
    }
    
    // 点击paypal事件
    @IBAction func clickedPaypalAction(_ sender: AnyObject) {
        
        if validDouble(paypalToPay) > kOneInMillion { //paypal 需要支付的金额大于0，则paypal处于可用状态
            isSelectPaypal = !isSelectPaypal
        }
        if isSelectPaypal == true {
            paypalIcon.image = UIImage(named: "icon_paypal_sel")
        } else {
            paypalIcon.image = UIImage(named: "icon_paypal_unsel")
        }
    }
    
}

extension SSTBalancePayView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString: NSString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        let str = validString(toBeString)
        if string == "\n" {
            return true
        }
        guard str.isValidMoney || str.count == 0 else {
            return false
        }
        if validDouble(toBeString) > validDouble(wallet) {
            walletAmount.text = wallet.formatCWithoutCurrency()
            return false
        }
        if validDouble(toBeString) > totalToPay {
            walletAmount.text = totalToPay.formatCWithoutCurrency()
            return false
        }
        paypalToPay = totalToPay - validDouble(walletAmount.text)
        paypalAmount.text = paypalToPay.formatC()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let str = textField.text
        if (str?.count)! > 0 {
            let dNumber = validDouble(str)
            walletAmount.text = dNumber.formatCWithoutCurrency()
        }
        if validDouble(str) > validDouble(wallet) {
            walletAmount.text = wallet.formatCWithoutCurrency()
        }
        if validDouble(str) > totalToPay {
            walletAmount.text = totalToPay.formatCWithoutCurrency()
        }
        paypalToPay = totalToPay - validDouble(walletAmount.text)
        paypalAmount.text = paypalToPay.formatC()
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let str = textField.text
        if (str?.count)! > 0 {
            let dNumber = validDouble(str)
            walletAmount.text = dNumber.formatCWithoutCurrency()
        }
        if validDouble(str) > validDouble(wallet) {
            walletAmount.text = wallet.formatCWithoutCurrency()
        }
        if validDouble(str) > totalToPay {
            walletAmount.text = totalToPay.formatCWithoutCurrency()
        }
        
        paypalToPay = totalToPay - validDouble(walletAmount.text)
        paypalAmount.text = paypalToPay.formatC()
        if paypalToPay <= kOneInMillion {
            paypalIcon.image = UIImage(named: "icon_paypal_unsel")
            isSelectPaypal = false
            
        } else {
            paypalIcon.image = UIImage(named: "icon_paypal_sel")
            isSelectPaypal = true
        }
//        if let block = selectWalletBlock{
//            block(isSelectedCell, validDouble(amount.text))
//        }
        
    }

}
