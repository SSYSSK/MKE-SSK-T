//
//  SSTPayResultVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/23/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTPayResultVC: SSTBaseVC {
    
    var order: SSTOrder!
    var payResult: SSTPayResult!
    
    @IBOutlet weak var payFailedReasonLable: UILabel!
    @IBOutlet weak var payFailedView: UIView!
    @IBOutlet weak var paySucceedView: UIView!
    @IBOutlet weak var paySuccessTitle: UILabel!
    @IBOutlet weak var paySuccessDiscription: UILabel!
    
    @IBOutlet weak var viewOrderButtonWithinScuccedView: UIButton!
    @IBOutlet weak var viewOrderButtonWithinFailedView: UIButton!
    
    var isPayAgainButtonEnable = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.backButton?.isHidden = true
        
        if payResult.isSuccessful {
            paySucceedView.isHidden = false
            
            paySuccessTitle.text = kOrderResultOK
            paySuccessDiscription.text = payResult.msg
        } else {
            paySucceedView.isHidden = true
            payFailedReasonLable.text = payResult?.msg
        }
        
        payFailedView.isHidden = !paySucceedView.isHidden
        
        if order == nil {
            viewOrderButtonWithinScuccedView.isHidden = true
            viewOrderButtonWithinFailedView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        var tmpArray = [UIViewController]()
        if (self.navigationController?.viewControllers.validObjectAtIndex(0) as? SSTCartVC) != nil { // from cart
            if let firstVC = self.navigationController?.viewControllers.first {
                tmpArray.append(firstVC)
            }
        } else {  // from order list or order details
            for ind in 0 ... 2 {
                if let tmpVC = self.navigationController?.viewControllers.validObjectAtIndex(ind) as? UIViewController {
                    if ind < 2 {
                        tmpArray.append(tmpVC)
                    } else if ind == 2 && tmpVC.isKind(of: SSTOrderDetailVC.classForCoder()) {
                        tmpArray.append(tmpVC)
                    }
                }
            }
        }
        if let lastVC = self.navigationController?.viewControllers.last {
            tmpArray.append(lastVC)
        }
        self.navigationController?.viewControllers = tmpArray
        
//        if let balanceOrderListVC = self.navigationController?.viewControllers.validObjectAtIndex(validInt(self.navigationController?.viewControllers.count) - 2) as? SSTBalanceOrderListVC {
//            balanceOrderListVC.fetchData()
//        }
        
        if self.payResult?.isSuccessful == true {
            let vcCnt = validInt(self.navigationController?.viewControllers.count)
            for ind in 1 ..< vcCnt {
                if let orderDetailVC = self.navigationController?.viewControllers.validObjectAtIndex(vcCnt - ind) as? SSTOrderDetailVC {
                    orderDetailVC.refreshOrder()
                } else if let orderVC = self.navigationController?.viewControllers.validObjectAtIndex(vcCnt - ind) as? SSTOrderVC {
                    orderVC.refreshViewAfterPaid()
                }
            }
        }
    }
    
    @IBAction func clickedPayAgainButton(_ sender: AnyObject) {
        
        if self.isPayAgainButtonEnable == false {
            return
        }
        
        SSTProgressHUD.show(view: self.view)
        self.isPayAgainButtonEnable = false
        SSTOrder.recalculateOrderPrice(order.id) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            self.isPayAgainButtonEnable = true
            if error == nil {
                self.order = data as! SSTOrder
                self.performSegue(withIdentifier: SegueIdentifier.toOrderPayment.rawValue, sender: self)
            } else if validInt(data) == APICodeType.MainOrderIsInProcess.rawValue {
                let alertView = SSTAlertView(title: nil, message: validString(error))
                alertView.addButton("Cancel") {
                }
                alertView.addButton("OK") { // 支付时，合并的订单已经不是未发货状态，则需要重现选择物流方式
                    self.performSegue(withIdentifier: SegueIdentifier.toOrderShipping.rawValue, sender: self)
                }
                alertView.show()
            } else {
                SSTToastView.showError("\(validString(error))")
            }
        }
    }

    @IBAction func clickedViewOrderEvetns(_ sender: AnyObject) {
        if (self.navigationController?.viewControllers.validObjectAtIndex(0) as? SSTCartVC) != nil { // from cart
            self.performSegue(withIdentifier: SegueIdentifier.toOrderDetail.rawValue, sender: self)
        } else {
            let vcCnt = validInt(self.navigationController?.viewControllers.count)
            for ind in 1 ..< vcCnt {
                if let tmpVC = self.navigationController?.viewControllers.validObjectAtIndex(vcCnt - ind) as? SSTOrderDetailVC {
                    _ = self.navigationController?.popToViewController(tmpVC, animated: true)
                    return
                }
            }
            self.performSegue(withIdentifier: SegueIdentifier.toOrderDetail.rawValue, sender: self)
        }
    }
    
    @IBAction func clickedContinueShoppingButton(_ sender: AnyObject) {
        self.tabBarController?.selectedIndex = TabIndexType.home.rawValue
        _ = self.navigationController?.popToRootViewController(animated: false)
    }
}

// MARK: -- Segue delegate

extension SSTPayResultVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case toOrderPayment         = "toOrderPayment"
        case toOrderList            = "toOrderList"
        case toOrderDetail          = "toOrderDetail"
        case toOrderShipping        = "toOrderShipping"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toOrderShipping.rawValue:
            let destVC = segue.destination as! SSTOrderShippingDetailVC
            destVC.order = self.order
        case SegueIdentifier.toOrderPayment.rawValue:
            let destVC = segue.destination as! SSTOrderPaymentVC
            destVC.order = self.order
        case SegueIdentifier.toOrderDetail.rawValue:
            let destVC = segue.destination as! SSTOrderDetailVC
            destVC.orderId = self.order.id
        default:
            break
        }
    }
    
}
