//
//  SSTCardInfoCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kPaymentCardImageViewBorderColor = RGBA(0x70, g: 0x6f, b: 0xfd, a: 1)

class SSTCardInfoCell: SSTBaseCell {

    @IBOutlet weak var cardIcon: UIButton!
    @IBOutlet weak var CODButton: UIButton!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var cardIconTopConstraint: NSLayoutConstraint!
    
    var clickToCODBlock:(() -> Void)?
    var clickPaymentTypeBlock:(() -> Void)?
    
    func setData(paymentType: SSTPaymentType, amount: Double) {
        
        if let url = URL(string: paymentType.paymentlogo) {
            cardIcon.af_setImage(for: UIControlState.normal, url: url)
        }
            
        if validString(paymentType.tip).trim().isEmpty {
            tipLabel.text = ""
            cardIconTopConstraint.constant = (SSTBasePayVC.getPaymentOptionCellHeight(tip: "") - cardIcon.height) / 2
        } else {
            tipLabel.text = "(\(validString(paymentType.tip)))"
            cardIconTopConstraint.constant = 5
        }
        
        total.text = amount.formatC()
     }
    
    func setStyle(selected: Bool) {
        if selected {
            cardIcon.alpha = 1
            cardIcon.setBorder(color: kPaymentCardImageViewBorderColor, width: 1)
            cardIcon.backgroundColor = kPurpleBgClolor
            total.textColor = RGBA(0x70, g: 0x6f, b: 0xfd, a: 1)
        } else {
            cardIcon.alpha = 0.7
            cardIcon.setBorder(color: UIColor.lightGray, width: 0.5)
            cardIcon.backgroundColor = UIColor.clear
            total.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func clickedPaymentAction(_ sender: AnyObject) {
        clickPaymentTypeBlock?()
    }
    
    @IBAction func clickedCODButtonAction(_ sender: AnyObject) {
        clickToCODBlock?()
    }
 }
