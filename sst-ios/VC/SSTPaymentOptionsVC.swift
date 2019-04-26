//
//  SSTPaymentOptionsVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/6.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kShipViaMyFexExAcountId = "21"
let kPaymentOptionsRowHeight:CGFloat = 49

class SSTPaymentOptionsVC: SSTBasePayVC, UITextViewDelegate {
    
    @IBOutlet weak var placeOrderButton: UIButton!
    
    fileprivate var remarkTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitOrderEvent(_ sender: AnyObject) {
        
//        guard paymentIdSelected != nil else {
//            SSTToastView.showError(kOrderPaymentTypeTip)
//            return
//        }
        
        if isViaAcountSelected && viaAccountValue.isEmpty {
            SSTToastView.showError(kOrderShippingAccountTip)
            return
        }
        
        SSTProgressHUD.showWithMaskOverFullScreen()
        self.placeOrderButton.isEnabled = false
        SSTOrder.createOrder(
            itemIds:biz.cart.itemIds,
            billingAddressId: validString(self.billingAddress?.id),
            shippingAddressId: validString(self.shippingAddress?.id),
            shippingCompanyId: validString(self.shippingcostInfo?.companyId),
            orderPaymentId: paymentTypeId,
            orderNote: remarkTextView.text,
            discountFlag: requestDiscountFlag,
            mergeOrderId: validString(lastMergableOrder?.id),
            mergeShippingTargetShippingId: validString(lastMergableOrder?.orderShippingId),
            mergeShippingRemarks: "",
            useWalletAmount: amountWithWalletToPay,
            customerShippingAcc: needShippingAccount ? validString(viaAccountValue) : "",
            warehouses: self.order.warehouses
            ) { (data, error) in
                if error == nil, let tmpOrder = data as? SSTOrder {
                    self.order = tmpOrder
                    SSTOrder.payOrder(orderId: validString(self.order.id),
                                      paymentId: validInt(self.paymentIdSelected),
                                      useWalletAmount: self.amountWithWalletToPay,
                                      orderFinalTotal: self.order.priceOfCurrentPaymentType,
                                      payAnywayForDiscountReq: 0) { (data, error) in
                        if error == nil {
                            self.prePay(data: data, error: error, button: self.placeOrderButton)
                        } else {
                            SSTToastView.showError(validString(error))
                        }
                    }
                } else {
                    SSTProgressHUD.dismiss(view: self.view)
                    if validString(error).isNotEmpty {
                        SSTToastView.showError(validString(error))
                    }
                    self.placeOrderButton.isEnabled = true
                }
        }
    }
    
    // MARK: -- UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.view.endEditing(true)
        }
        return true
    }
    
    // MARK: -- UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if (indexPath.row == 2 && order.taxInfo == nil) || indexPath.row == 3 {
                if let cell = loadNib("\(SSTPaymentOptionNoteCell.classForCoder())") as? SSTPaymentOptionNoteCell {
                    remarkTextView = cell.viewWithTag(100) as! UITextView
                    remarkTextView.delegate = self
                    return cell
                }
            }
        }
        return super.tableView(tableView, cellForRowAt: indexPath)
    }
    
    // MARK: -- Segue delegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch validString(segue.identifier) {
        case SegueIdentifier.toPayResult.rawValue:
            biz.cart.fetchData()
        default:
            break
        }
    }
}
