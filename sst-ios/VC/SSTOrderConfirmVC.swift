//
//  SSTOrderConfirmVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTOrderConfirmVC: SSTBaseOrderShippingVC {
    
    @IBOutlet weak var continueButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func fetchInfo() {
        SSTProgressHUD.show(view: self.view)
        SSTCart.fetchShippingInfoBeforePlacingOrder(itemsId: biz.cart.itemIds, shippingAddressId: validString(self.shippingAddress?.id)) { (data, error) in
            self.doAfterFetchInfo(data, error)
        }
    }
    
    // MARK: -- Clicked Check Out Button
    
    @IBAction func billingEvent(_ sender: AnyObject) {
        if validWhenContinue() == false {
            return
        }
        
        if canAddShippingAccount && validBool(shippingAccountCell?.selectButton.isSelected) && validString(shippingAccountCell?.fedexAccountTF.text).isEmpty {
            SSTToastView.showError(kOrderShippingAccountTip)
            return
        }
        
        SSTProgressHUD.show(view: self.view)
        self.continueButton.isEnabled = false
        SSTOrder.precalculateOrderPrice(itemIds: biz.cart.itemIds,
                                        orderPaymentId: "",
                                        mergeShippingTargeOrderId: mergableOrder?.id != nil ? validString(mergableOrder?.id) : "",
                                        mergeShippingId: validString(mergableOrder?.orderShippingId),
                                        mergeShippingRemarks: "",
                                        discountRequestFlag: false,
                                        billingAddressId: validString(billingAddress?.id),
                                        shippingAddressId: validString(shippingAddress?.id),
                                        shippingCompanyId: validString(shippingCostInfoClicked?.companyId),
                                        shippingAddressCountryCode: validString(shippingAddress?.countryCode),
                                        shippingAddressStateCode: validString(shippingAddress?.stateCode),
                                        customerShippingAcc: shippingAccount,
                                        warehouses: validArray(self.order?.warehouses) as! [SSTOrderWarehouse]) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            self.continueButton.isEnabled = true
            if error == nil {
                if let order = data as? SSTOrder {
                    self.order = order
                    if self.navigationController != nil {
                        self.performSegueWithIdentifier(SegueIdentifier.SegueToPaymentOptionsVC, sender: nil)
                    }
                } else {
                    SSTToastView.showError(kOrderConfirmContinueFailed)
                }
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
}

