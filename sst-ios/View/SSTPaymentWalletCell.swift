//
//  SSTPaymentWalletCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/28.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTPaymentWalletCell: SSTBaseCell {
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var currencyTypeLabel: UILabel!
    @IBOutlet weak var balanceValueButton: UIButton!
    @IBOutlet weak var balanceValueButton2: UIButton!
    
    fileprivate var walletData: SSTWalletData!
    fileprivate var orderAmount = 0.0   // 选中的支付方式所需要支付的订单总金额，当输入的数字大于它时，应自动更改为订单总金额
    fileprivate var isWalletSelected = false
    
    var updateBlock:((_ isWalletSelected: Bool, _ walletAmount: Double) -> Void)?
    var balanceValueClick: (() -> Void)?
    
    static func getBalanceValueButtonTitle(totalAmount: Double) -> String {
        return "(" + totalAmount.formatC() + ")"
    }
    
    static func isNeedNewLine(balanceValueButtonTitle: String, isWalletSelected: Bool) -> Bool {
        let existedViewWidth: CGFloat = (37 + 22 + 117 + 80) + 20
        return balanceValueButtonTitle.sizeByWidth(font: 14).width > kScreenWidth - existedViewWidth && isWalletSelected
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        amount.keyboardType = .decimalPad
        let inputV = SSTInputAccessoryView()
        inputV.buttonClick = { [weak self] in
            if let tTF = self?.amount {
                _ = self?.textFieldShouldReturn(tTF)
            }
        }
        amount.inputAccessoryView = inputV
    }
    
    func setData(info: SSTWalletData, orderAmount: Double, isWalletSelected: Bool, amountToPayWithWallet: Double) {
        self.walletData = info
        self.orderAmount = orderAmount
        self.isWalletSelected = isWalletSelected
        
        if validDouble(walletData.totalAmount) > kOneInMillion {
            let balanceValueButtonTitle = SSTPaymentWalletCell.getBalanceValueButtonTitle(totalAmount: validDouble(walletData.totalAmount))
            if !SSTPaymentWalletCell.isNeedNewLine(balanceValueButtonTitle: balanceValueButtonTitle, isWalletSelected: self.isWalletSelected) {
                balanceValueButton.isHidden = false
                balanceValueButton.setTitle(balanceValueButtonTitle, for: .normal)
                balanceValueButton2.isHidden = true
            } else {
                balanceValueButton.isHidden = true
                balanceValueButton2.setTitle(balanceValueButtonTitle, for: .normal)
                balanceValueButton2.isHidden = false
            }
        } else {
            balanceValueButton.isHidden = true
            balanceValueButton2.isHidden = true
        }
        
        if amountToPayWithWallet > kOneInMillion {
            amount.text = amountToPayWithWallet.formatMoney()
        }
        
        refreshUI()
    }
    
    func refreshUI() {
        if isWalletSelected {
            selectBtn.setImage(UIImage(named: kCheckboxSelectedImgName), for: UIControlState.normal)
            amount.isHidden = false
        } else {
            selectBtn.setImage(UIImage(named: kCheckboxNormalImgName), for: UIControlState.normal)
            amount.isHidden = true
        }
        currencyTypeLabel.isHidden = amount.isHidden
    }
   
    @IBAction func selectWalletAction(_ sender: AnyObject) {
        isWalletSelected = !isWalletSelected
        refreshUI()
        updateBlock?(isWalletSelected, isWalletSelected ? validDouble(amount.text) : 0)
    }
    
    @IBAction func clickedBalanceValueButton(_ sender: Any) {
        balanceValueClick?()
    }
}

extension SSTPaymentWalletCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
        
        if toBeString.isNotEmpty && validBool(toBeString.isValidMoney) == false {
            return false
        }
        
        let minAmount = min(validDouble(self.orderAmount), validDouble(walletData.totalAmount))
        if validMoney(toBeString) > minAmount {
            amount.text = minAmount.formatMoney()
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        updateBlock?(isWalletSelected, validMoney(amount.text))
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateBlock?(isWalletSelected, validMoney(amount.text))
        
        textField.resignFirstResponder()
    }
}


