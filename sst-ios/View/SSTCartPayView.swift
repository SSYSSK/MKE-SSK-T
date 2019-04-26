//
//  SSTCartPayView.swift
//  sst-ios
//
//  Created by Zal Zhang on 7/18/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTCartPayView: UIView {
    
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var originTotalLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    
    @IBOutlet weak var msgViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate var promoMsgView = loadNib("\(SSTPromoMsgView.classForCoder())") as! SSTPromoMsgView
    
    var checkoutButtonClick: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        promoMsgView.frame.size = CGSize(width: kScreenWidth, height: kPromoMsgHeight)
        self.addSubview(promoMsgView)
    }
    
    func setPromoMsgView() {
        promoMsgView.setArray(array: validArray(biz.cart.tipsOfOrderDiscountAndFreeShippingCompany))
        if validInt(biz.cart.tipsOfOrderDiscountAndFreeShippingCompany.count) > 0 {
            msgViewHeightConstraint.constant = 35
            promoMsgView.isHidden = false
        } else {
            msgViewHeightConstraint.constant = 0
            promoMsgView.isHidden = true
        }
    }
    
    func setData(_ total: Double, oldAmount: Double, count: Int) {
        self.totalLabel.text = total.formatC()
        
        if oldAmount - total > kOneInMillion {
            self.originTotalLabel.isHidden = false
            self.originTotalLabel.text = oldAmount.formatC()
        } else {
            self.originTotalLabel.isHidden = true
            self.originTotalLabel.text = ""
        }
        
        let savedPrice = oldAmount - total
        if savedPrice > kOneInMillion {
            self.saveLabel.isHidden = false
            self.saveLabel.text = "Save \(savedPrice.formatC())"
        } else {
            self.saveLabel.isHidden = true
            self.saveLabel.text = ""
        }
    }
    
    @IBAction func clickedCheckoutButton(_ sender: Any) {
        self.checkoutButtonClick?()
    }
}
