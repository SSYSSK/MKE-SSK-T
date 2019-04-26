 //
//  SSTOrderHeadCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
let kButtonBorderColor = "BCBDFB"
 
class SSTOrderListCell: SSTBaseCell {

    @IBOutlet weak var orderIcon: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var orderNumber: UILabel!
    @IBOutlet weak var date: UILabel!

    @IBOutlet weak var toPayBtn: UIButton!
    @IBOutlet weak var payStatus: UILabel!
    
    @IBOutlet weak var codIconHeight: NSLayoutConstraint!
    @IBOutlet weak var payButtonWidthConstraint: NSLayoutConstraint!
    
    fileprivate let kPayButtonWidth: CGFloat = 50
    
    var orderClicked: ((_ order: SSTOrder) -> Void)?
    var clickToPayBlock:((_ order: SSTOrder) ->Void)?
    var clickConfirmBlock:((_ order: SSTOrder) ->Void)?
    var clickHiddenBlock:((_ order: SSTOrder) -> Void)?
    
    var order: SSTOrder! {
        didSet {
            toPayBtn.setBorder(color: UIColor.hexStringToColor(kButtonBorderColor), width: 1)
            
            orderNumber.text = order.id
            date.text = order.dateCreated?.formatHMmmddyyyy()
            
            amount.text = order.orderFinalTotal.formatC()
            toPayBtn.isHidden = true
            
            payStatus.text = "(\(validString(order.orderStatusDesc)))"
            
            if order.isPayable {
                payButtonWidthConstraint.constant = kPayButtonWidth
                self.toPayBtn.isHidden = false
                self.toPayBtn.setTitle(kOrderButtonTitlePay, for: UIControlState())
            } else if order.isArchivable {
                payButtonWidthConstraint.constant = kPayButtonWidth
                toPayBtn.isHidden = false
                toPayBtn.setTitle(kOrderButtonTitleHide, for: UIControlState())
            } else {
                payButtonWidthConstraint.constant = 0
            }
        }
    }
    
    @IBAction func clickedToPayBtnAction(_ sender: AnyObject) {
        if toPayBtn.titleLabel?.text == kOrderButtonTitlePay {
            if let block = clickToPayBlock {
                block(order)
            }
        } else {
            if let block = clickHiddenBlock {
                block(order)
            }
        }
       
    }

}
