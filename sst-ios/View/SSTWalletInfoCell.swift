//
//  SSTWalletInfoCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/21.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTWalletInfoCell: SSTBaseCell {

    @IBOutlet weak var paymentType: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var orderNumberTitle: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var orderNumberImg: UIImageView!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var paidAmount: UILabel!
    @IBOutlet weak var dateLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderClickedBtn: UIButton!
    
    var clickedOrderBlock:((String)->Void)?
    
    var walletInfo: SSTWallet! {

        didSet {
            let paid = validDouble(walletInfo.endAmount) - validDouble(walletInfo.beginAmount)
            
            var paymentStr = ""
            switch walletInfo.actType {
            case 0:
                paymentStr = "Add Balance"
            case 1:
                paymentStr = "Deduct Balance"
            case 2:
                paymentStr = "Purchase"
            case 3:
                if paid > kOneInMillion {
                    paymentStr = "Order Revise Refund"
                } else {
                    paymentStr = "Purchase"
                }
            case 4:
                paymentStr = "Order Cancel Refund"
            default:
                break
            }
            paymentType.text = paymentStr
            
            remarkLabel.text = walletInfo.remark
            
            date.text = walletInfo.date?.formatHMmmddyyyy()
            
            if validString(walletInfo.orderId) != "" {
                orderNumber.text = walletInfo.orderId
                orderNumberTitle.isHidden = false
                orderNumber.isHidden = false
                orderNumberImg.isHidden = false
                orderClickedBtn.isHidden = false
                dateLabelTopConstraint.constant = 4.5
            } else {
                orderNumberTitle.isHidden = true
                orderNumber.isHidden = true
                orderNumberImg.isHidden = true
                orderClickedBtn.isHidden = true
                dateLabelTopConstraint.constant = -8
            }
            
            balance.text = "Balance \(validString(walletInfo.beginAmount?.formatC()))"
            if paid > kOneInMillion {
                paidAmount.textColor = UIColor.red
                paidAmount.text = "+ \(paid.formatC())"
            } else {
                paidAmount.textColor = UIColor.colorWithCustom(115 , g: 184 , b: 115 )
                paidAmount.text = "- \(fabs(paid).formatC())"
            }
        }
    }
    
    @IBAction func clickedOrderEvent(_ sender: Any) {

        if let block = clickedOrderBlock {
            block(validString(walletInfo.orderId))
        }
    }
}
