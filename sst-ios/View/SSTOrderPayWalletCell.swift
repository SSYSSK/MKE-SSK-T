//
//  SSTOrderPayWalletCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/30.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTOrderPayWalletCell: SSTBaseCell {

   
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var amount: UITextField!
    
    var isSelectedCell = false
    var selectedPaymentAmount = 0.0
    var info = SSTWalletData()
    var paymentTypeAmount = 0.0   //选中的支付方式所产生的所有费用，当输入的数目大于它时，应自动更改为paymentTypeAmount
    
    var selectWalletBlock:((_ isSelected: Bool, _ walletAmount: Double )->Void)?
    
    func setData(info: SSTWalletData, paymentAmount: Double) {
        self.info = info
        self.paymentTypeAmount = paymentAmount
        balance.text = "(\(validDouble(info.totalAmount?.formatCWithoutCurrency())))"
        if isSelectedCell == true {
            selectBtn.setImage(UIImage(named: "icon_checkbox_sel"), for: UIControlState.normal)
        } else {
            selectBtn.setImage(UIImage(named: "icon_checkbox_normal"), for: UIControlState.normal)
        }
        if isSelectedCell == false {
            amountView.isHidden = true
        } else {
            amountView.isHidden = false
            if selectedPaymentAmount > kOneInMillion {
                amount.text = selectedPaymentAmount.formatCWithoutCurrency()
            }
        }
        
    }

    @IBAction func selectWallAction(_ sender: AnyObject) {
        isSelectedCell = !isSelectedCell
        if let block = selectWalletBlock{
            block(isSelectedCell, validDouble(amount.text))
        }
    }
    
}

extension SSTOrderPayWalletCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString: NSString = (textField.text! as NSString).replacingCharacters(in: range, with: string) as NSString
        let str = validString(toBeString)
        if string == "\n" {
            return true
        }
        guard str.isValidFormatForMoney || str.characters.count == 0 else {
            return false
        }
        if validDouble(toBeString) > validDouble(info.totalAmount) {
            amount.text = info.totalAmount?.formatCWithoutCurrency()
            return false
        }
        if validDouble(toBeString) > paymentTypeAmount {
            amount.text = paymentTypeAmount.formatCWithoutCurrency()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let str = textField.text
        if (str?.characters.count)! > 0 {
            let dNumber = validDouble(str)
            amount.text = dNumber.formatCWithoutCurrency()
        }
        if validDouble(str) > validDouble(info.totalAmount) {
            amount.text = info.totalAmount?.formatCWithoutCurrency()
        }
        if validDouble(str) > paymentTypeAmount {
            amount.text = paymentTypeAmount.formatCWithoutCurrency()
        }
        if let block = selectWalletBlock{
            block(isSelectedCell, validDouble(amount.text))
        }
        textField.resignFirstResponder()
        return true
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let str = textField.text
        if (str?.characters.count)! > 0 {
            let dNumber = validDouble(str)
            amount.text = dNumber.formatCWithoutCurrency()
        }
        if validDouble(str) > validDouble(info.totalAmount) {
            amount.text = info.totalAmount?.formatCWithoutCurrency()
        }
        if validDouble(str) > paymentTypeAmount {
            amount.text = paymentTypeAmount.formatCWithoutCurrency()
        }
        if let block = selectWalletBlock{
            block(isSelectedCell, validDouble(amount.text))
        }
        
    }
    
}

