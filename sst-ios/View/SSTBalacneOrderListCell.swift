//
//  SSTBalacneOrderListCell.swift
//  sst-ios
//
//  Created by Amy on 2017/4/24.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTBalacneOrderListCell: SSTBaseCell {
    
    @IBOutlet weak var chooseIcon: UIImageView!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var CODIconHeightConstraint: NSLayoutConstraint!
    
    var selectOrderBlock:((_ order: SSTOrder)-> Void)?
    var clickToPayBlock:((_ order: SSTOrder) ->Void)?
    
    var orderInfo: SSTOrder! {
        didSet {
            self.orderNumber.text = orderInfo.id
            let totalToPay = orderInfo.orderFinalTotal - orderInfo.paidTotal
            self.total.text = totalToPay.formatC()
            self.date.text = orderInfo.dateCreated?.formatHMmmddyyyy()
            if orderInfo.paymentMethod == SSTPaymentMethod.cod_SELECTED.rawValue {
                self.CODIconHeightConstraint.constant = 18
            } else {
                self.CODIconHeightConstraint.constant = 0
            }
            payBtn.layer.borderColor = payBtn.tintColor.cgColor
            payBtn.layer.borderWidth = 0.8
        }
    }
    
    func setState(selected: Bool) {
        if selected {
            chooseIcon.image = UIImage(named: kSelectedImageName)
        } else {
            chooseIcon.image = UIImage(named: kUnselectedImageName)
        }
    }
    
    @IBAction func selectedCellEvent(_ sender: AnyObject) {
        selectOrderBlock?(self.orderInfo)
    }
    
    @IBAction func clickedPayAction(_ sender: AnyObject) {
        if payBtn.titleLabel?.text == kOrderButtonTitlePay {
            clickToPayBlock?(orderInfo)
        }
    }
}
