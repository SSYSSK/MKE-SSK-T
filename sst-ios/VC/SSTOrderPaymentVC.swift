//
//  SSTOrderPaymentVC.swift
//  sst-ios
//
//  Created by Amy on 2017/3/30.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTOrderPaymentVC: SSTBasePayVC {
    
    @IBOutlet weak var requestMoreDiscountView: UIView!
    @IBOutlet weak var requestMoreDiscountLabel: UILabel!
    
    @IBOutlet weak var continueButton: UIButton!
    
    fileprivate var isPayButtonEnable = true
    fileprivate var payAnywayForDiscountReq: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if order.discountRequestStatus != nil && validInt(order.discountRequestStatus) >= 0 && validInt(order.discountRequestStatus) <= 2 {
            requestMoreDiscountLabel.text = validString(kOrderDiscountRequestStatusTips.validObjectAtIndex(validInt(order.discountRequestStatus)))
        } else {
            requestMoreDiscountView.removeFromSuperview()
        }
    }
    
    fileprivate func payOrderEvent() {
        self.isPayButtonEnable = false
        SSTProgressHUD.showWithMaskOverFullScreen()
        SSTOrder.payOrder(orderId: validString(self.order.id),
            paymentId: validInt(paymentIdSelected),
            useWalletAmount: self.amountWithWalletToPay,
            orderFinalTotal: self.order.priceOfCurrentPaymentType,
            payAnywayForDiscountReq: validInt(self.payAnywayForDiscountReq)) { (data, error) in
                if error == nil {
                    self.prePay(data: data, error: error, button: self.continueButton)
                } else {
                    SSTToastView.showError(validString(error))
                    self.isPayButtonEnable = true
                }
        }
    }
    
    // Mark: -- pay event
    
    @IBAction func clickedPayAction(_ sender: AnyObject) {
        
        if self.isPayButtonEnable == false {
            return
        }
        
        if order.discountRequestStatus == 0 {
            let msg = validString(kOrderDiscountRequestStatusTexts.validObjectAtIndex(validInt(order.discountRequestStatus)))
            let alertView = SSTAlertView(title: nil, message: msg)
            alertView.addButton("OK", action: {
                alertView.dismiss()
            })
            alertView.addButton("Pay Anyway", action: {
                self.payAnywayForDiscountReq = 1
                self.payOrderEvent()
            })
            alertView.show()
        } else {
            self.payOrderEvent()
        }
    }
    
    // MARK: -- UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if order.taxInfo == nil {
                return 2
            }
            return 3
        case 1:
            return super.tableView(tableView, numberOfRowsInSection: section)
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return getSSTPaymentInfoCell(indexPath: indexPath)
            case 1, 2, 3:
                if indexPath.row == 1 && order.taxInfo != nil {
                    return getSSTPaymentOptionTaxCell(indexPath: indexPath, taxInfo: order.taxInfo)
                }
                if (indexPath.row == 1 && order.taxInfo == nil) || (indexPath.row == 2 && order.taxInfo != nil) {
                    return getSSTPaymentOptionShippingCell(indexPath: indexPath)
                }
            default:
                break
            }
        } else {
            if indexPath.row == 0 {
                if let cell = tableView.dequeueCell(SSTOrderPaymentHeadCell.self) {
                    if order.paidTotal > kOneInMillion {
                        cell.paidAmountInfo.isHidden = false
                        cell.paidAmountInfo.text = "(Paid: \(order.paidTotal.formatC()))"
                    } else {
                        cell.paidAmountInfo.isHidden = true
                    }
                    return cell
                }
            } else if indexPath.row == 1 && validDouble(walletInfo.totalAmount) > kOneInMillion {
                return getSSTPaymentWalletCell(indexPath: indexPath)
            } else {
                return getSSTCardInfoCell(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
    
    override func getSSTPaymentOptionShippingCell(indexPath: IndexPath) -> UITableViewCell {
        if let cell = super.getSSTPaymentOptionShippingCell(indexPath: indexPath) as? SSTPaymentOptionShippingCell {
            cell.shippingFee.text = validDouble(order.shippingFee).formatC()
            return cell
        } else {
            return UITableViewCell()
        }
    }
}

