//
//  SSTOrderShippingDetailVCViewController.swift
//  sst-ios
//
//  Created by Amy on 2017/5/18.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kOrderDetailShippingAddress = "orderShippingAddress"
let kOrderDetailBilingAddress   = "orderBillingAddress"

class SSTOrderShippingDetailVC: SSTBaseOrderShippingVC {
    
    var orderId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func fetchInfo() {
        SSTProgressHUD.show(view: self.view)
        SSTOrder.getOrderShippingDetails(orderId: validString(orderId), callback: { (data, error) in
            self.doAfterFetchInfo(data, error)
        })
    }

    @IBAction func clickedContinueAction(_ sender: AnyObject) {
        if validWhenContinue() == false {
            return
        }
        
        SSTProgressHUD.show(view: self.view)
        SSTOrder.updateOrderShppingDetailInfo(orderId: validString(self.orderId),
                                              orderShipping: validString(shippingCostInfoClicked?.companyId),
                                              shippingAddressId: validString(shippingAddress?.id),
                                              billingAddressId: validString(billingAddress?.id),
                                              customerShippingAcc: shippingAccount,
                                              mergeableOrderId: mergableOrder?.id != nil ? validString(mergableOrder?.id) : "",
                                              warehouses: validArray(self.order?.warehouses) as! [SSTOrderWarehouse] ) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                if let order = data as? SSTOrder {
                    self.order = order
                    self.performSegue(withIdentifier: SegueIdentifier.SegueToPaymentOptionsVC.rawValue, sender: self)
                } else {
                    SSTToastView.showError(kOrderConfirmContinueFailed)
                }
            } else {
                SSTToastView.showError(kOrderConfirmContinueFailed)
            }
        }
    }
}
