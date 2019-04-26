//
//  SSTBalanceOrderList.swift
//  sst-ios
//
//  Created by Amy on 2017/4/21.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kBillingId = "billingId"
let kEmptyViewOriginY: CGFloat = kScreenNavigationHeight + 40

class SSTBalanceOrderListVC: SSTBasePayVC {
    
    var balanceOrderData: SSTBalanceOrderData!

    @IBOutlet weak var mandatoryBtn: UIButton!
    @IBOutlet weak var codBtn: UIButton!
    @IBOutlet weak var shipfirstBtn: UIButton!
    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var combineTotal: UILabel!
    @IBOutlet weak var payViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var indexLineLeftConstraint: NSLayoutConstraint!
    
    fileprivate var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    fileprivate var isShowWalletInfo: Bool = false //当用户钱包余额为0，则不显示余额信息
    fileprivate var orderClicked: SSTOrder?
    
    fileprivate var selectedIndex = 0
    fileprivate var currentOrderList: SSTBalanceOrder {
        get {
            switch selectedIndex {
            case 0:
                return balanceOrderData.mandatoryOrders
            case 1:
                return balanceOrderData.codOrders
            case 2:
                return balanceOrderData.shipOrders
            default:
                return SSTBalanceOrder()
            }
        }
    }
    
    var ordersSelected = [SSTOrder]()
    
    var orderIdsSelected : [String] {
        get {
            var ids = [String]()
            for order in self.ordersSelected {
                ids.append(order.id)
            }
            return ids
        }
    }
    
    var ordersTotalToPay: Double {
        get {
            var total: Double = 0
            for order in self.ordersSelected {
                total += order.amountUnpaid
            }
            return total
        }
    }

    enum SegueIdentifier: String {
        case segueToOrderDetailVC  = "ToOrderDetailVC"
        case segueToOrderPaymentVC = "ToOrderPaymentOpitonVC"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.estimatedRowHeight = 44
        myTableView.rowHeight = UITableViewAutomaticDimension
        
        self.balanceOrderData.delegate = self
        
        self.setSelectInfo()
        
        walletInfo.delegate = self
        walletInfo.getWalletBalance()
        
        emptyView.frame = CGRect(x: 0, y: kEmptyViewOriginY, width: kScreenWidth, height: kScreenHeight - kEmptyViewOriginY)
        emptyView.setData(imgName: kNoOrderImgName, msg: kNoBalanceOrderTip, buttonTitle: "", buttonVisible: false)
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
    }
    
    override func fetchData() {
        SSTProgressHUD.show(view: self.view)
        self.balanceOrderData.getDueOrders()
    }
    
    func findOrderInOrdersSelected(orderId: String) -> Bool {
        for order in ordersSelected {
            if orderId == order.id {
                return true
            }
        }
        return false
    }
    
    func updateOrdersSelected(order: SSTOrder) {
        if findOrderInOrdersSelected(orderId: order.id) {
            for ind in 0 ..< ordersSelected.count {
                if ordersSelected[ind].id == order.id {
                    self.ordersSelected.remove(at: ind)
                    break
                }
            }
        } else {
            ordersSelected.append(order)
        }
        self.combineTotal.text = ordersTotalToPay.formatC()
    }

    func setSelectInfo( ) {
        switch selectedIndex {
        case 0:
            mandatoryBtn.setTitleColor(kPurpleColor, for: UIControlState.normal)
            codBtn.setTitleColor(kDarkGaryColor, for: UIControlState.normal)
            shipfirstBtn.setTitleColor(kDarkGaryColor, for: UIControlState.normal)
            indexLineLeftConstraint.constant = 0
        case 1:
            mandatoryBtn.setTitleColor(kDarkGaryColor, for: UIControlState.normal)
            codBtn.setTitleColor(kPurpleColor, for: UIControlState.normal)
            shipfirstBtn.setTitleColor(kDarkGaryColor, for: UIControlState.normal)
            indexLineLeftConstraint.constant = kScreenWidth / 3
        case 2:
            mandatoryBtn.setTitleColor(kDarkGaryColor, for: UIControlState.normal)
            codBtn.setTitleColor(kDarkGaryColor, for: UIControlState.normal)
            shipfirstBtn.setTitleColor(kPurpleColor, for: UIControlState.normal)
            indexLineLeftConstraint.constant = kScreenWidth / 3 * 2
        default:
            break
        }
        
        if currentOrderList.orders.count <= 0 {
            myTableView.isHidden = true
            payViewHeightConstraint.constant = 0
        } else {
            payViewHeightConstraint.constant = 44
            myTableView.isHidden = false
        }
        combineTotal.text = ordersTotalToPay.formatC()
        emptyView.isHidden = !myTableView.isHidden
        
        myTableView.reloadData()
    }
    
    @IBAction func selectedSegmentAction(_ sender: AnyObject) {
        let button = sender as! UIButton
        selectedIndex = button.tag - 1
        self.setSelectInfo()
    }
    
    @IBAction func clickedCombinePaymentAction(_ sender: AnyObject) {
        guard ordersSelected.count > 0 else {
            SSTToastView.showError("There should be at least one order to pay")
            return
        }
        
        paymentTypeData.delegate = self
        paymentTypeData.getBalancePaymentType()
    }
    
    func createPaymentView() {
        let balancePayView = loadNib("\(SSTBalancePayView.classForCoder())") as! SSTBalancePayView
        balancePayView.frame = UIScreen.main.bounds
        balancePayView.setData(paymentData: paymentTypeData, totalToPay: ordersTotalToPay, wallet: validDouble(walletInfo.totalAmount), orderIds: orderIdsSelected)
        balancePayView.combinePayBlock = { () -> Void in
            balancePayView.removeFromSuperview()
            SSTOrder.createBilling(orderIds: self.orderIdsSelected, callback: { (data, error) in
                if error == nil {
                    let billingId = validString(validDictionary(data)[kBillingId])
                    self.amountWithWalletToPay = validDouble(balancePayView.walletAmount.text)
                    if self.ordersTotalToPay.equal(self.amountWithWalletToPay) {
                        self.payBalanceOrdersWithWallet(total: self.ordersTotalToPay, billingId: billingId)
                    } else {
                        self.billingId = validString(billingId)
                        self.payWithPaypal(total: self.ordersTotalToPay - self.amountWithWalletToPay, billingId: validString(billingId))
                    }
                }
            })
        }
        let window = UIApplication.shared.delegate?.window
        window??.addSubview(balancePayView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch validString(segue.identifier) {
        case SegueIdentifier.segueToOrderDetailVC.rawValue:
            let destVC = segue.destination as! SSTOrderDetailVC
            destVC.orderId = self.orderClicked?.id
        case SegueIdentifier.segueToOrderPaymentVC.rawValue:
            let destVC = segue.destination as! SSTOrderPaymentVC
            destVC.order = self.orderClicked
        default:
            break
        }
    }
    
    override func refreshUI(_ data: Any?) {
        if (data as? SSTBalanceOrderData) != nil {
            SSTProgressHUD.dismiss(view: self.view)
            myTableView.reloadData()
        } else if (data as? SSTWalletData) != nil {
            walletInfo = data as! SSTWalletData
        } else if (data as? SSTPaymentTypeData) != nil {
            paymentTypeData = data as! SSTPaymentTypeData
            self.createPaymentView()
        }
    }

    // MARK: -- UITableViewDelegate, UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentOrderList.orders.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 5.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTBalacneOrderListCell.classForCoder())") as! SSTBalacneOrderListCell
        cell.orderInfo = currentOrderList.orders.validObjectAtIndex(indexPath.section) as? SSTOrder
        cell.setState(selected: self.findOrderInOrdersSelected(orderId: cell.orderInfo.id))
        cell.selectOrderBlock = { [weak self] order in
            self?.updateOrdersSelected(order: order)
            cell.setState(selected: validBool(self?.findOrderInOrdersSelected(orderId: order.id)))
        }
        cell.clickToPayBlock = { [weak self] order in
            SSTProgressHUD.show(view: self?.view)
            SSTOrder.recalculateOrderPrice(order.id) {[weak self] (data, error) in
                SSTProgressHUD.dismiss(view: self?.view)
                if nil == error {
                    self?.orderClicked = data as? SSTOrder
                    self?.performSegue(withIdentifier: SegueIdentifier.segueToOrderPaymentVC.rawValue, sender: self)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.orderClicked = currentOrderList.orders[indexPath.section]
        self.performSegue(withIdentifier: SegueIdentifier.segueToOrderDetailVC.rawValue, sender: self)
    }
}
