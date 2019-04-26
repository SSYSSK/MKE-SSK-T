//
//  SSTOrderDetailVCViewController.swift
//  sst-ios
//
//  Created by Amy on 16/6/21.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kOrderButtonTitlePay    = "Pay"
let kOrderButtonTitleHide   = "Archive"
let kOrderButtonTitleCancel = "Cancel"

fileprivate let kOrderDetailCellNote            = "OrderNote"
fileprivate let kOrderDetailCellDate            = "OrderDateAndStatus"
fileprivate let kOrderDetailCellStatus          = "OrderStatus"
fileprivate let kOrderDetailCellTrackingNbr     = "OrderTrackingNbr"

let kOrderTrackingNbrCellNbrHeight: CGFloat     = 20

class SSTOrderDetailVC: SSTBaseVC {
    
    var orderId: String!

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var buttonsView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var buttonViewHightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paidView: UIView!
    @IBOutlet weak var walletPaid: UILabel!
    @IBOutlet weak var amountDue: UILabel!

    var order: SSTOrder!
    fileprivate var itemClicked: SSTItem?
    fileprivate var trackingNbrClicked: SSTShippingInfoVos?
    
    fileprivate var previousOrderVC: SSTOrderVC? {
        get {
            return self.navigationController?.childViewControllers.validObjectAtIndex(validInt(self.navigationController?.childViewControllers.count) - 2) as? SSTOrderVC
        }
    }
    
    fileprivate var rowsWithinSectoin2: [String] {
        get {
            var rRowIds = [String]()
            if order.note.isNotEmpty {
                rRowIds.append(kOrderDetailCellNote)
            }
            rRowIds.append(kOrderDetailCellDate)
            rRowIds.append(kOrderDetailCellStatus)
//            if order.shippingInfoVos.count > 0 {
//                rRowIds.append(kOrderDetailCellTrackingNbr)
//            }
            return rRowIds
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title  = "Order #\(validString(orderId))"
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        myTableView.register(UINib(nibName: "SSTOrderItemCell", bundle: nil), forCellReuseIdentifier: "SSTOrderItemCell")
        
        // set button border color
        cancelButton.setBorder(color: UIColor.hexStringToColor(kButtonBorderColor), width: 1)
        editButton.setBorder(color: UIColor.hexStringToColor(kButtonBorderColor), width: 1)
        payBtn.setBorder(color: UIColor.hexStringToColor(kButtonBorderColor), width: 1)
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = myTableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.upPullLoadData()
        }
        
        self.buttonViewHightConstraint.constant = 0
        
        SSTProgressHUD.show(view: self.view)
        refreshOrder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        if let vc = self.navigationController?.childViewControllers.validObjectAtIndex(validInt(self.navigationController?.childViewControllers.count) - 2) as? SSTOrderVC {
            vc.resetViewAfterLoginedByAnotherAccount()
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func upPullLoadData() {
        refreshOrder()
    }
    
    func refreshOrder() {
        SSTOrder.fetchOrder(orderId) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            self.refreshView(data: data, error: error)
        }
    }
    
    func refreshView(data: Any?, error: Any?) {
        if error == nil, let tOrder = data as? SSTOrder {
            self.myTableView.endHeaderRefreshing(.success, delay: 0.5)
            self.order = tOrder
            self.myTableView.reloadData()
            
            if validInt(self.order.hidByCustomer) != 1 {
                buttonsView.isHidden = false
                
                self.cancelButton.isHidden = !self.order.isCancelable
                self.editButton.isHidden = self.order.paidTotal > kOneInMillion ? true : false
                self.editButton.setTitle((self.order.approvalStatus == SSTOrderApprovalStatus.canceled.rawValue ? "Reorder" : "Edit"), for: .normal)
                
                if self.order.isPayable {
                    self.payBtn.isHidden = false
                    self.payBtn.setTitle(kOrderButtonTitlePay, for: UIControlState())
                } else if self.order.isArchivable {
                    self.payBtn.isHidden = false
                    self.payBtn.setTitle(kOrderButtonTitleHide, for: UIControlState())
                } else {
                    self.payBtn.isHidden = true
                }
                
                if self.order.isPayable && self.order.paidTotal > kOneInMillion && self.order.amountUnpaid > kOneInMillion {
                    self.paidView.isHidden = false
                    self.walletPaid.text = "Paid: \(self.order.paidTotal.formatC())"
                    self.amountDue.text = "Amount Due: \(self.order.amountUnpaid.formatC())"
                } else {
                    self.paidView.isHidden = true
                }
                
                if let orderListVC = self.previousOrderVC {
                    orderListVC.orderData.orders[validInt(orderListVC.sectionClicked)] = self.order
                    orderListVC.myTableView.reloadSections([validInt(orderListVC.sectionClicked)], with: .none)
                }
                
                if self.cancelButton.isHidden && self.editButton.isHidden && self.payBtn.isHidden {
                    self.buttonViewHightConstraint.constant = 0
                } else {
                    self.buttonViewHightConstraint.constant = 44
                }
                
                var buttons = [UIButton]()
                if !self.payBtn.isHidden {
                    buttons.append(self.payBtn)
                }
                if !self.editButton.isHidden {
                    buttons.append(self.editButton)
                }
                if !self.cancelButton.isHidden {
                    buttons.append(self.cancelButton)
                }
                for ind in 0 ..< buttons.count {
                    buttons[ind].frame = CGRect(x: kScreenWidth - 10 - CGFloat(ind + 1) * (buttons[ind].width + 10), y: 9, width: 65, height: 25)
                }
                
                buttonsView.isHidden = buttons.count == 0
            } else {
                buttonsView.isHidden = true
            }
        } else {
            self.myTableView.endHeaderRefreshing(.failure, delay: 0.5)
            SSTToastView.showError(validString(error))
            self.payBtn.isHidden = true
            TaskUtil.delayExecuting(0.5, block: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    @IBAction func clickedCancelButton(_ sender: Any) {
        SSTProgressHUD.show(view: self.view)
        SSTOrder.preCanceOrder(self.order.id) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                let mAC = UIAlertController(title: "", message: validString(validDictionary(data)["checkCancelOrderRefundTotalMsg"]), preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
                let okAction = UIAlertAction(title: "Yes", style: .default, handler: { action in
                    SSTProgressHUD.show(view: self.view)
                    SSTOrder.cancelOrder(self.order.id) { data, error in
                        SSTProgressHUD.dismiss(view: self.view)
                        if error == nil {
                            SSTToastView.showSucceed(String(format: kOrderCancelledTip, self.order.id))
                            self.refreshView(data: data, error: error)
                        } else {
                            SSTToastView.showError(validString(error))
                        }
                    }
                })
                mAC.addAction(cancelAction)
                mAC.addAction(okAction)
                self.present(mAC, animated: true, completion: nil)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    @IBAction func clickedEditButton(_ sender: Any) {
        SSTProgressHUD.show(view: self.view)
        SSTOrder.buyAgain(orderId: self.orderId) { data, error in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                biz.cart.update(validDictionary(data))
                biz.cart.refreshUI(biz.cart)
                gMainTC?.selectedIndex = TabIndexType.cart.rawValue
                if let nc = gMainTC?.childViewControllers.validObjectAtIndex(TabIndexType.cart.rawValue) as? UINavigationController {
                    nc.popToRootViewController(animated: false)
                }
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    @IBAction func clickedPayButton(_ sender: AnyObject) {
        let button = sender as! UIButton
        if button.titleLabel?.text == kOrderButtonTitleHide {
            SSTOrder.clickedHideButton(hideButton: button, orderId: self.orderId, afterCallbackBlock: { [weak self] data, error in
                if nil == error {
                    self?.previousOrderVC?.refreshViewAfterArchived()
                    self?.navigationController?.popViewController(animated: true)
                }
            })
        } else {
            SSTOrder.clickedPayButton(payButton: button, orderId: self.orderId)
        }
    }
}

// MARK:-- UITableViewDelegate, UITableViewDataSource

extension SSTOrderDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if order != nil {
            return 3 + order.warehouses.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 2 {
            return 1
        } else if section == 2 {
            return rowsWithinSectoin2.count
        } else if section < 3 + self.order.warehouses.count {
            var tCnt = 2
            if let wh = self.order.warehouses.validObjectAtIndex(section - 3) as? SSTOrderWarehouse {
                tCnt += (wh.shippingInfoVos.count > 0 ? 1 : 0) + wh.orderItems.count
            }
            return tCnt
        } else {
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section < self.myTableView.numberOfSections - 1 {
            return 0.01
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section > 2 && indexPath.section < 3 + self.order.warehouses.count && indexPath.row == 2 { // tracking nbr cells
            let owh = self.order?.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse
            if validInt(owh?.shippingInfoVos.count) > 0 {
                return validCGFloat(owh?.shippingInfoVos.count) * kOrderTrackingNbrCellNbrHeight + 14 + (validInt(owh?.shippingInfoVos.count) == 1 ? 10 : 3)
            }
        } else if indexPath.section == 3 + self.order.warehouses.count {
            if indexPath.row == 1 { // tax
                if order.tax > kOneInMillion {
                    return 44 - 9 + validCGFloat(self.order.warehouses.count) * kWarehouseTaxViewHeight
                }
                return 50
            } else if indexPath.row == 2 {  // shipping
                return 44 - 17 + validCGFloat(self.order.warehouses.count) * kWarehouseShippingViewHeight
            }
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 || indexPath.section == 1 {
            if indexPath.row == 0, let cell = tableView.dequeueCell(SSTOrderAddressCell.self) {
                cell.addressName.text = indexPath.section == 0 ? "Billing Address": "Shipping Address"
                cell.addressInfo = indexPath.section == 0 ? order.billingAddress: order.shippingAddress
                return cell
            }
        } else if indexPath.section == 2 {
            switch validString(rowsWithinSectoin2.validObjectAtIndex(indexPath.row)) {
            case kOrderDetailCellNote:
                if let cell = tableView.dequeueCell(SSTOrderNoteCell.self) {
                    cell.notes.text = order.note
                    return cell
                }
            case kOrderDetailCellDate:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTOrderDetailInfoCell.classForCoder())", for: indexPath) as? SSTOrderDetailInfoCell {
                    cell.date.text = order.dateCreated?.formatHMmmddyyyy()
                    return cell
                }
            case kOrderDetailCellStatus:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SSTOrderStatusCell", for: indexPath)
                (cell.viewWithTag(1001) as? UILabel)?.text = order.orderStatusDesc
                return cell
            default:
                break
            }
        } else if indexPath.section < 3 + self.order.warehouses.count {
            let owh = self.order?.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse
            if indexPath.row == 0 {
                let cell = loadNib("\(SSTOrderShippingFromCell.classForCoder())") as! SSTOrderShippingFromCell
                cell.info = owh
                return cell
            } else if indexPath.row == 1 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SSTShippingStatusCell", for: indexPath)
                (cell.viewWithTag(1001) as? UILabel)?.text = owh?.shippingStatusDesc
                return cell 
            } else if indexPath.row == 2 && validInt(owh?.shippingInfoVos.count) > 0 {
                let cell = loadNib("\(SSTOrderShippingInfoCell.classForCoder())") as! SSTOrderShippingInfoCell
                cell.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 44)
                cell.setData(tranckingNbrs: order.shippingInfoVos)
                cell.clickTrackingBlock = { [weak self] item in
                    self?.trackingNbrClicked = item as? SSTShippingInfoVos
                    self?.performSegue(withIdentifier: SegueIdentifier.SegueToWebVC.rawValue, sender: nil)
                }
                return cell
            } else {
                let itmStartInd = 2 + (validInt(owh?.shippingInfoVos.count) > 0 ? 1 : 0)
                let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTOrderItemCell.classForCoder())") as! SSTOrderItemCell
                if let itm = owh?.orderItems.validObjectAtIndex(indexPath.row - itmStartInd) as? SSTOrderItem {
                    cell.orderItem = itm
                    cell.bottomLineV.isHidden = indexPath.row == order.items.count - 1 + itmStartInd
                }
                return cell
            }
        } else {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SSTOrderSubtotalCell", for: indexPath) as! SSTOrderDetailFeeCell
                cell.setData(order.subTotal, originPrice: order.orderTotal)
                return cell
            } else if indexPath.row == 1 {
                if let cell = loadNib("\(SSTPaymentOptionTaxCell.classForCoder())") as? SSTPaymentOptionTaxCell {
                    cell.setDataForOrderDetail(tax: order.tax, warehouses: self.order.warehouses)
//                    cell.setDataWithoutWarehouseInfo(tax: order.tax)

                    return cell
                }
            } else if indexPath.row == 2 {
                if let cell = loadNib("\(SSTPaymentOptionShippingCell.classForCoder())") as? SSTPaymentOptionShippingCell {
                    cell.setDataForOrderDetail(shippingFee: order.shippingFee, origialFee: order.nativeShippingTotal, warehouses: self.order.warehouses)
                    return cell
                }
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SSTOrderTotalCell", for: indexPath)
                (cell.viewWithTag(1001) as? UILabel)?.text = order.orderFinalTotal.formatC()
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section > 2 && indexPath.section < 3 + self.order.warehouses.count {
            if let wh = self.order.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse {
                let itemStartIndex = 2 + (wh.shippingInfoVos.count > 0 ? 1 : 0)
                //如果有track number，cnt初始值为3，否则为2
                if indexPath.row >= itemStartIndex {
                    let wh = order.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse
                    itemClicked = wh?.orderItems.validObjectAtIndex(indexPath.row - itemStartIndex) as? SSTOrderItem
                    guard validString(itemClicked?.id).isNotEmpty else {
                        SSTToastView.showError(kOrderDetailProductErrorText)
                        return
                    }
                    self.performSegueWithIdentifier(.SegueToItemDetailVC, sender: nil)
                }
            }
        }
    }
}

// MARK:-- Segue Delegate

extension SSTOrderDetailVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToOrderPayVC      = "toOrderPaymentVC"
        case SegueToItemDetailVC    = "toItemDetailVC"
        case SegueToOrderShippingVC = "ToOrderShippingVC"
        case SegueToWebVC           = "toWeb"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.SegueToOrderShippingVC.rawValue:
            let destVC = segue.destination as! SSTOrderShippingDetailVC
            destVC.orderId = validString(self.order.id)
            destVC.order = self.order    // the order will be updated by calling api
        case SegueIdentifier.SegueToOrderPayVC.rawValue:
            let destVC = segue.destination as! SSTOrderPaymentVC
            if let order = sender as? SSTOrder {
//                destVC.balanceDueFlag = order.balaneDueFlage
                destVC.order = order
//                destVC.paidBlock = { data, error in
//                    if error == nil {
//                        SSTProgressHUD.show(view: self.view)
//                        TaskUtil.delayExecuting(1.9, block: {
//                            SSTProgressHUD.dismiss()
//                            self.refreshOrder()
//                        })
//                    }
//                }
            }
            destVC.order = self.order
        case SegueIdentifier.SegueToItemDetailVC.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            destVC.item = itemClicked
        case SegueIdentifier.SegueToWebVC.rawValue:
            let destVC = segue.destination as! SSTWebVC
            destVC.webTitle = validString("Tracking #\(validString(trackingNbrClicked?.trackingNumber))")
            destVC.webUrl = validString(trackingNbrClicked?.trackingUrl)
        default:
            break
        }
    }
}
