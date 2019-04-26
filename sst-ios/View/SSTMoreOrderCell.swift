//
//  SSTMoreOrderCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTMoreOrderCell: SSTBaseCell {

    @IBOutlet weak var unpaidReddot: UIView!
    @IBOutlet weak var unPaidCntLabel: UILabel!
    @IBOutlet weak var processReddot: UIView!
    @IBOutlet weak var inProcessCntLabel: UILabel!
    @IBOutlet weak var transitReddot: UIView!
    @IBOutlet weak var inTransitCntLabel: UILabel!
    
    @IBOutlet weak var orderCellHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var balanceOrderViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var balanceView: UIView!
    
    var hasBalanceOrder: Bool! {
        didSet {
            if hasBalanceOrder == true {
                balanceOrderViewHeight.constant = 35
                balanceView.isHidden = false
            } else {
                balanceOrderViewHeight.constant = 0
                balanceView.isHidden = true
            }
        }
    }
    
    var clickedOrderBlock:((_ sender: AnyObject) ->Void)?
    var clickedBalanceOrderBlock:((_ sender: AnyObject) -> Void)?
    
    var orderdata: SSTOrderData! {
        didSet {
            unpaidReddot.isHidden = orderdata.unpaidNums == 0 ? true: false
            processReddot.isHidden = orderdata.inProcess == 0 ? true: false
            transitReddot.isHidden = orderdata.inTransit == 0 ? true: false
            
            unPaidCntLabel.text = validString(orderdata.unpaidNums)
            inProcessCntLabel.text = validString(orderdata.inProcess)
            inTransitCntLabel.text = validString(orderdata.inTransit)
        }
    }
    
    @IBAction func clickedOrderAction(_ sender: AnyObject) {
        clickedOrderBlock?(sender)
    }
    
    @IBAction func clickedBalanceOrderAction(_ sender: AnyObject) {
        clickedBalanceOrderBlock?(sender)
    }
   
}
