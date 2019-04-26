//
//  SSTBasePayVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/16/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kPaypalCountryState = "countryState"

class SSTBasePayVC: SSTBaseVC, PayPalPaymentDelegate, UITextFieldDelegate, SSTUIRefreshDelegate {
    
    var lastMergableOrder: SSTOrder?
    var shippingcostInfo: SSTShippingCostInfo?
    var shippingAddress: SSTShippingAddress?
    var billingAddress: SSTShippingAddress?
    var shippingAccount = ""
    
    var order: SSTOrder!
    var paidBlock: RequestCallBack?
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var itemCounts: UILabel!  // saved money
    @IBOutlet weak var oldTotalLabel: UILabel!
    
    @IBOutlet weak var checkoutViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestDiscountBtn: UIButton!
    @IBOutlet weak var requestInfo: UILabel!
    @IBOutlet weak var discountTipsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountTipsLabel: UILabel!
    
    var paymentTypeData = SSTPaymentTypeData()
    var walletInfo = SSTWalletData()
    
    var paymentIdSelected: String = validString(SSTOrderPaymentType.paypal.rawValue)
    var amountWithWalletToPay: Double = 0
    
    var requestDiscountFlag: Bool = false
    var billingId : String = ""
    
    var isWalletSelected: Bool = false // flag to indicate user selected the wallet to pay
    
    var shippingCell: SSTPaymentOptionShippingCell?
    var shippingCellIndexPathRow: Int?
    var isViaAcountSelected = false
    var viaAccountTF: UITextField!
    var viaAccountValue = ""
    
    var needShippingAccount: Bool {
        get {
            for wh in self.order.warehouses {
                if wh.isNeedShippingAccount {
                    return true
                }
            }
            return false
        }
    }
    
    var priceInfo: SSTPaymentMethodOrderPrice? {
        get {
            return self.order.getOrderPrice(paymentTypeId: validString(paymentIdSelected))
        }
    }
    
    var paymentTypeId: String {
        get {
            return amountWithWalletToPay.equal(self.order.amountUnpaid) ? validString(SSTOrderPaymentType.wallet.rawValue) : paymentIdSelected // validString(self.priceInfo?.paymentId)
        }
    }
    
    var totalDiscount: Double {
        get {
            return order.discount + validDouble(self.priceInfo?.shippingFeeDiscount)
        }
    }
    
    var countryState: String {
        get {
            return "\(validString(order.shippingAddress?.countryCode))_\(validString(order.shippingAddress?.stateCode))"
        }
    }
    
    var recipientName: String {
        get {
            return (validString(self.order.shippingAddress?.firstName) + " " + validString(self.order.shippingAddress?.lastName)).trim()
        }
    }
    
    var vcShippingFee: Double {
        get {
            var toDeductShippingFee: Double = 0
            if self.viaAccountValue.trim().isNotEmpty { // deduct the order total off shipping fee for the fedex shipping company
                for wh in self.order.warehouses {
                    if wh.isNeedShippingAccount {
                        toDeductShippingFee += validDouble(wh.shippingFinalTotal)
                    }
                }
            }
            return toDeductShippingFee
        }
    }
    
    enum SegueIdentifier: String {
        case toPayResult    = "toPayResultVC"
        case toWallet       = "toWallet"
        case toWebPaypal    = "toWebPaypal"
    }
    
    var webUrl: String?
    
    var payResult: SSTPayResult?
    
    static func getPaymentOptionCellHeight(tip: String?) -> CGFloat {
        if validBool(validString(tip).trim().isEmpty) {
            return kPaymentOptionsRowHeight
        } else {
            return 33 + 10 + validString(tip).trim().sizeByWidth(font: 12, width: kScreenWidth - 38 - 10 - kLabelSpaceWidth).height
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.refreshView()
        
        if order.canApplyMoreDiscount == false {
            requestDiscountBtn.removeFromSuperview()
            requestInfo.removeFromSuperview()
        }
        
        if order.canApplyMoreDiscount == false || totalDiscount <= kOneInMillion {
            checkoutViewHeightConstraint.constant = 45
        } else {
            checkoutViewHeightConstraint.constant = 55
        }
        
        if order.discountTips?.isNotEmpty == true {
            let strHeight: CGFloat! = order.discountTips?.sizeByWidth(font: 13 , width: kScreenWidth - 20).height
            discountTipsViewHeightConstraint.constant = strHeight
            discountTipsLabel.text = order.discountTips
        } else {
            discountTipsViewHeightConstraint.constant = 0
        }
        
        paymentTypeData.delegate = self
        walletInfo.delegate = self
        
        self.fetchData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SSTProgressHUD.dismiss(view: self.view)
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func fetchData() {
        if order.isBalanceOrder == true { //如果是欠款订单，那么请求欠款支付方式接口；否则请求支付方式接口
            paymentTypeData.getBalancePaymentType()
        } else {
            let shippingCompanyId: String = lastMergableOrder == nil ? validString(order.orderShippingId) : validString(lastMergableOrder?.orderShippingId)
            let paymentId: String = lastMergableOrder == nil ? validString(order.orderPayment) : validString(lastMergableOrder?.orderPayment)
            
            paymentTypeData.getPaymentType(
                validString(order.shippingAddress?.countryCode),
                codOrderPrice: self.order.priceOfCOD,
                shippingCompanyId: shippingCompanyId,
                orderId: validString(order.id),
                mergeTargetOrderPaymentId: validInt(paymentId)
            )
        }
        
        walletInfo.getWalletBalance()
    }
    
    func refreshView() {
        self.refreshBottomView(total: self.order.orderFinalTotal)
        self.myTableView.reloadData()
    }
    
    func refreshBottomView(total: Double) {
        self.total.text = total.formatC() // self.priceInfo?.orderFinalTotal.formatC()
        
        if totalDiscount > kOneInMillion {
            itemCounts.isHidden = false
            itemCounts.text = "Save \(totalDiscount.formatC())"
            oldTotalLabel.text = (total + totalDiscount).formatC()
        } else {
            itemCounts.text = ""
            oldTotalLabel.text = ""
        }
    }
    
    @IBAction func clickedRequestDiscountAction(_ sender: AnyObject) {
        requestDiscountBtn.isSelected = !requestDiscountFlag
        requestDiscountFlag = requestDiscountBtn.isSelected
        if requestDiscountFlag == true {
            requestDiscountBtn.setBackgroundImage(UIImage(named: kCheckboxSelectedImgName), for: UIControlState.normal)
        } else {
            requestDiscountBtn.setBackgroundImage(UIImage(named: kCheckboxNormalImgName), for: UIControlState.normal)
        }
    }
    
    func prePay(data: Any?, error: Any?, button: UIButton?) {
        if error == nil, let tmpOrder = data as? SSTOrder {
            self.order = tmpOrder
            self.pay()
        } else {
            SSTProgressHUD.dismiss(view: self.view)
            button?.isEnabled = true
            if validInt(data) == APICodeType.UnclearedShip.rawValue || validInt(data) == APICodeType.UnclearedMandatory.rawValue || validInt(data) == APICodeType.UnclearedCOD.rawValue {
                let errorMessageView = loadNib("\(SSTMessageBox.classForCoder())") as! SSTMessageBox
                errorMessageView.frame = UIScreen.main.bounds
                errorMessageView.errorMessage = validString(error)
                getTopWindow()?.addSubview(errorMessageView)
            } else if validString(error).isNotEmpty {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func pay() {
        self.payResult = SSTPayResult(isSuccessful: true, msg: "", type: SSTOrderPaymentType(rawValue: validInt(self.order.orderPayment)))

        if self.order.amountUnpaid < kOneInMillion { // if the order total is equal to zero, then succeessful, sometimes one item maybe be free to sale.
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        } else if self.requestDiscountFlag == true { //申请了更多折扣，或者选择COD支付方式，则直接跳转到订单结果页
            self.payResult?.type = SSTOrderPaymentType.requestDiscount
            self.payResult?.msg = kOrderResultRequestDiscountTip
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        } else if amountWithWalletToPay.equal(self.order.amountUnpaid) {
            self.payWithWallet()
        } else if validInt(self.order.orderPayment) == SSTOrderPaymentType.paypal.rawValue {
            let total = self.order.amountUnpaid - amountWithWalletToPay
            self.payWithPaypal(total: total, billingId: validString(self.order.billingId))
        } else {
            if validInt(self.order.orderPayment) == SSTOrderPaymentType.COD.rawValue {
                self.payResult?.msg = kOrderResultCODTip
            } else if validInt(self.order.orderPayment) == SSTOrderPaymentType.localPickup.rawValue {
                //
            } else if validInt(self.order.orderPayment) == SSTOrderPaymentType.shipFirst.rawValue {
                //
            }
            if amountWithWalletToPay > kOneInMillion {
                self.payWithWallet()
            } else {
                SSTToastView.showError(kOrderPaymentTypeTip)
                self.payResult?.isSuccessful = false
                self.payResult?.msg = kOrderPaymentTypeTip
                self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
            }
        }
    }
    
    func payWithWallet() {
        SSTOrder.payOrderWithWallet(orderId: validString(self.order.id), useWalletAmount: amountWithWalletToPay, callback: { (data, error) in
            if error == nil {
                //
            } else {
                self.payResult?.isSuccessful = false
                self.payResult?.msg = validString(error)
            }
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        })
    }
    
    func payBalanceOrdersWithWallet(total: Double, billingId: String) {
        self.payResult = SSTPayResult(isSuccessful: true, msg: "", type: SSTOrderPaymentType(rawValue: validInt(self.order.orderPayment)))
        
        SSTProgressHUD.showWithMaskOverFullScreen()
        SSTOrder.payBalanceOrdersWithWallet(billingId: billingId, useWalletAmount: total, callback: { (data, error) in
            if error == nil {
                //
            } else {
                self.payResult?.msg = validString(error.debugDescription)
            }
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        })
    }
    
    func payWithPaypal(total: Double, billingId: String) {
        biz.getPaypalClientId(countryState: self.countryState) { data, error in
            if error == nil {
                let clientId = validString(validDictionary(data)["clientId"])
                if ( gPaypalClientId.isEmpty || gPaypalClientId == clientId ) && validString(validDictionary(data)["method"]) != "WEB" {
                    gPaypalClientId = clientId
                    self.doPayWithPaypalSDK(clientId: clientId, total: total, billingId: billingId)
                } else {
                    self.doPayWidthPaypalWEB(total: total, billingId: billingId)
                }
            } else {
                self.payResult = SSTPayResult(isSuccessful: false, msg: validString(error), type: SSTOrderPaymentType.paypal)
                self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
            }
        }
    }
    
    func doPayWidthPaypalWEB(total: Double, billingId: String) {
        let paras = [
            "billingId": billingId,
            "amount": total.formatMoney(),
            "returnUrl": kPaypalCreatePaymentUrl,
            "cancelUrl": kPaypalCancelPaymentUrl,
            "recipientName": self.recipientName,
            "apt": validString(self.order.shippingAddress?.apt),
            "city": validString(self.order.shippingAddress?.city),
            "state": validString(self.order.shippingAddress?.state),
            "zip": validString(self.order.shippingAddress?.zip),
            "countryCode": validString(self.order.shippingAddress?.countryCode),
            "countryState": validString(self.order.shippingAddress?.countryCode) + "_" + validString(self.order.shippingAddress?.stateCode)
        ]
        biz.createPayment(paras: paras, callback: { (data, error) in
            if error == nil {
                self.webUrl = validString(validString(data).toDictionary()?["approval_url"])
                self.performSegue(withIdentifier: SegueIdentifier.toWebPaypal.rawValue, sender: self)
            } else {
                self.payResult = SSTPayResult(isSuccessful: false, msg: validString(error), type: SSTOrderPaymentType.paypal)
                self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
            }
        })
    }
    
    func doPayWithPaypalDidCancel() {
        SSTProgressHUD.showWithMaskOverFullScreen()
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        self.payResult = SSTPayResult(isSuccessful: false, msg: kPaypalCancelResultText, type: SSTOrderPaymentType.paypal)
        if (self.navigationController?.viewControllers.validObjectAtIndex(0) as? SSTCartVC) != nil {    // from cart
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        } else if (self.navigationController?.viewControllers.last as? SSTBalanceOrderListVC) != nil {  // from balance order list vc
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        } else {
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        }
    }
    
    func doPayWithPaypalDidComplete(error: Any?, msg: String) {  // only be calling by using paypal web to pay
        if error == nil {
            self.doWalletPaymentAfterPaypalComplete(error: error, msg: msg)
        } else {
            self.goToPayResultVC(error: error, msg: msg)
        }
    }
    
    func doWalletPaymentAfterPaypalComplete(error: Any?, msg: String) {
        if self.order != nil && self.amountWithWalletToPay > kOneInMillion {
            SSTOrder.payOrderWithWallet(orderId: validString(self.order.id), useWalletAmount: self.amountWithWalletToPay, callback: { (data, error) in
                if error == nil {
                    self.goToPayResultVC(error: error, msg: "")
                } else {
                    self.goToPayResultVC(error: error, msg: kCartPayFaildWhenPaypalOKAndWalletFailedTip)
                }
            })
        } else if self.billingId != "" && self.amountWithWalletToPay > kOneInMillion {
            SSTOrder.payBalanceOrdersWithWallet(billingId: validString(self.billingId), useWalletAmount: self.amountWithWalletToPay, callback: { (data, error) in
                if error == nil {
                    self.goToPayResultVC(error: error, msg: "")
                } else {
                    self.goToPayResultVC(error: error, msg: kCartPayFaildWhenPaypalOKAndWalletFailedTip)
                }
            })
        } else {
            self.goToPayResultVC(error: nil, msg: "")
        }
    }
    
    func goToPayResultVC(error: Any?, msg: String) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        if error == nil {
            self.payResult = SSTPayResult(isSuccessful: true, msg: msg, type: SSTOrderPaymentType.paypal)
        } else {
            self.payResult = SSTPayResult(isSuccessful: false, msg: msg, type: SSTOrderPaymentType.paypal)
        }
        self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
    }
    
    func doPayWithPaypalSDK(clientId: String, total: Double, billingId: String) {
        let intent = PayPalPaymentIntent.sale
        let shortDesc = "Transaction #\(billingId)"
        let payment = PayPalPayment(amount: NSDecimalNumber(string: "\(total.formatMoney())"), currencyCode: "USD", shortDescription: shortDesc, intent: intent)
        payment.custom = validString(biz.user.firstName)
        payment.shippingAddress = PayPalShippingAddress(recipientName: recipientName,
                                                        withLine1: validString(self.order.shippingAddress?.apt),
                                                        withLine2: "",
                                                        withCity: validString(self.order.shippingAddress?.city),
                                                        withState: validString(self.order.shippingAddress?.state),
                                                        withPostalCode: validString(self.order.shippingAddress?.zip),
                                                        withCountryCode: validString(self.order.shippingAddress?.countryCode))
        
        PayPalMobile.initializeWithClientIds(forEnvironments: [
            PayPalEnvironmentProduction : clientId,
            PayPalEnvironmentSandbox: clientId
            ])
        PayPalMobile.preconnect(withEnvironment: kPayPalMode)
        
        let payPalConfiguration = PayPalConfiguration()
        payPalConfiguration.acceptCreditCards = true
        payPalConfiguration.payPalShippingAddressOption = PayPalShippingAddressOption.none
        
        if payment.processable {
            if let payPalPaymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfiguration, delegate: self) {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
                self.present(payPalPaymentViewController, animated: false, completion: nil)
            } else {
                self.payResult = SSTPayResult(isSuccessful: false, msg: kPaypalOpenErrorTip, type: SSTOrderPaymentType.paypal)
                self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
            }
        } else {
            self.payResult = SSTPayResult(isSuccessful: false, msg: kPaypalSubtotalErrorTip, type: SSTOrderPaymentType.paypal)
            self.performSegue(withIdentifier: SegueIdentifier.toPayResult.rawValue, sender: self)
        }
    }
    
    // MARK: -- PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        let alertController = UIAlertController(title: "", message: kPaypalCancelTip, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            paymentViewController.dismiss(animated: true, completion: nil)
            self.doPayWithPaypalDidCancel()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        paymentViewController.present(alertController, animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController:PayPalPaymentViewController, didComplete didCompletePayment:PayPalPayment) {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        var mConfirmation  = didCompletePayment.confirmation
        mConfirmation["billing_id"] = didCompletePayment.shortDescription
        mConfirmation[kPaypalCountryState] = self.countryState
        
        SSTProgressHUD.showWithMaskOverFullScreen()
        biz.sendPaypalConfirmation(mConfirmation as NSDictionary) { (resp,err) -> Void in
            if err == nil { // have sent the confirmation to server successfully.
                self.doPayWithPaypalDidComplete(error: err, msg: SSTBasePayVC.getPaymentMsg(dict: validDictionary(resp)))
            } else { // store the confirmation in local, and send again next time wihtin home vc.
                var fileData = validArray(FileOP.unarchive(kPaypalConfirmationFileName))
                fileData.append(mConfirmation as AnyObject)
                if !FileOP.archive(kPaypalConfirmationFileName, object: fileData) {
                    printDebug(kCartArchivePaypalConfirmationErrorTip)
                }
                self.doPayWithPaypalDidComplete(error: nil, msg: "")
            }
        }
        
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    static func getPaymentMsg(dict: Dictionary<String, Any>?) -> String {
        if validString(dict?["state"]) != "completed" {
            return kPayWithStatePendingTip
        }
        return ""
    }
    
    // MARK: -- Segue delegate
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toPayResult.rawValue:
            let destVC = segue.destination as! SSTPayResultVC
            destVC.order = order
            destVC.payResult = self.payResult
        case SegueIdentifier.toWebPaypal.rawValue:
            let destVC = segue.destination as! UINavigationController
            if let paypalWebVC = destVC.childViewControllers.first as? SSTPaypalWebVC {
                paypalWebVC.webUrl = self.webUrl
            }
        default:
            break
        }
    }
    
    // MARK: -- TableView
    
    func getSSTPaymentInfoCell(indexPath: IndexPath) -> UITableViewCell {
        if let cell = loadNib("\(SSTPaymentInfoCell.classForCoder())") as? SSTPaymentInfoCell {
            cell.setData(price: order.subTotal, oldPrice: order.orderTotal, discount: order.discount)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func getSSTPaymentOptionTaxCell(indexPath: IndexPath, taxInfo: SSTFreeTaxInfo? = nil) -> UITableViewCell {
        if let cell = loadNib("\(SSTPaymentOptionTaxCell.classForCoder())") as? SSTPaymentOptionTaxCell {
            let orderTax = priceInfo == nil ? order.tax : validDouble(priceInfo?.taxTotal)
            cell.setData(tax: orderTax, taxInfo: taxInfo)
            orderTax > kOneInMillion ? cell.warehouses = self.order.warehouses : nil
            cell.clickToTaxBlock = {
                let taxVC = loadVC(controllerName: "\(SSTTaxVC.classForCoder())", storyboardName: kStoryBoard_More) as! SSTTaxVC
                self.navigationController?.pushViewController(taxVC, animated: true)
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    //from shipping detail vc
    
    func getSSTPaymentOptionShippingCell(indexPath: IndexPath) -> UITableViewCell {
        if let cell = loadNib("\(SSTPaymentOptionShippingCell.classForCoder())") as? SSTPaymentOptionShippingCell {
            cell.shippingCompanyName.text = self.shippingcostInfo != nil ? validString(self.shippingcostInfo?.name) : self.order.shippingCompanyName
            cell.shippingFee.text = validDouble(order.shippingTotal).formatC() // validDouble(priceInfo?.shippingTotal).formatC()
            cell.originShippingFeeLabel.text = validDouble(self.priceInfo?.shippingFeeDiscount) > kOneInMillion ? validDouble(priceInfo?.originShippingFee).formatC() : ""
            cell.warehouses = self.order.warehouses
            cell.setShippingAccountUI(needAccount: needShippingAccount, isSelected: isViaAcountSelected)
            self.viaAccountTF = cell.fedexAccountTF
            self.viaAccountTF.delegate = self
            cell.selectButtonClick = { isSelected in
                self.isViaAcountSelected = isSelected
                self.myTableView.reloadData()
            }
            self.shippingCell = cell
            self.shippingCellIndexPathRow = indexPath.row
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func getPaymentTypeByIndexPath(_ indexPath: IndexPath) -> SSTPaymentType? {
        var paymentInfo: SSTPaymentType?
        if validDouble(walletInfo.totalAmount) > kOneInMillion {
            paymentInfo = paymentTypeData.paymentTypes.validObjectAtIndex(indexPath.row - 2) as? SSTPaymentType
        } else {
            paymentInfo = paymentTypeData.paymentTypes.validObjectAtIndex(indexPath.row - 1) as? SSTPaymentType
        }
        return paymentInfo
    }

    func getSSTCardInfoCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = loadNib("\(SSTCardInfoCell.classForCoder())") as! SSTCardInfoCell
        
        let paymentInfo = getPaymentTypeByIndexPath(indexPath)
        if let tPaymentInfo = paymentInfo {
            let paymentTotal = validDouble(self.order.orderFinalTotal) - self.amountWithWalletToPay - self.order.paidTotal - vcShippingFee
            cell.setData(paymentType: tPaymentInfo, amount: paymentTotal)
            cell.setStyle(selected: tPaymentInfo.paymentId == paymentIdSelected && !self.amountWithWalletToPay.equal(self.order.amountUnpaid))
        }
        
        cell.clickPaymentTypeBlock = {
            self.paymentIdSelected = validString(paymentInfo?.paymentId)
            self.refreshView()
        }
        
        return cell
    }
    
    func getSSTPaymentWalletCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = loadNib("\(SSTPaymentWalletCell.classForCoder())") as! SSTPaymentWalletCell
        let orderUnpaidOfWallet = self.order.getPriceByPaymetTypeId(paymentTypeId: validString(SSTOrderPaymentType.wallet.rawValue)) - self.order.paidTotal
        cell.updateBlock = { isWalletSelected, walletAmount in
            self.isWalletSelected = isWalletSelected
            
            self.amountWithWalletToPay = walletAmount
//            if self.isWalletSelected == true {
//                if self.amountWithWalletToPay.equal(orderUnpaidOfWallet) {
//                    self.paymentIdSelected = validString(SSTOrderPaymentType.wallet.rawValue)
//                } else {
//                    self.paymentIdSelected = validString(SSTOrderPaymentType.paypal.rawValue)
//                }
//            } else {
//                self.paymentIdSelected = nil
//            }
            if self.myTableView.numberOfSections > 1 {
                self.myTableView.reloadSections([1], with: .none)
            }
        }
        cell.balanceValueClick = {
            self.performSegue(withIdentifier: SegueIdentifier.toWallet.rawValue, sender: self)
        }
        cell.setData(info: walletInfo, orderAmount: orderUnpaidOfWallet, isWalletSelected: self.isWalletSelected, amountToPayWithWallet: self.amountWithWalletToPay)
        return cell
    }
    
    // MARK: -- UITextFieldDelegate
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.viaAccountTF {
            self.viaAccountValue = validString(textField.text)
            self.refreshBottomView(total: self.order.orderFinalTotal - vcShippingFee)
            self.myTableView.reloadSections([1], with: UITableViewRowAnimation.none)
        }
    }
    
    // MARK: -- SSTUIRefreshDelegate
    
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        myTableView.reloadData()
    }
}

// MARK: -- UITableViewDelegate, UITableViewDataSource

extension SSTBasePayVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if order.taxInfo == nil {
                return 3
            }
            return 4
        case 1:
            if validDouble(walletInfo.totalAmount) > kOneInMillion {
                return 2 + paymentTypeData.paymentTypes.count
            }
            return 1 + paymentTypeData.paymentTypes.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0.1
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 10
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                return kPaymentOptionsRowHeight * 2
            case 1, 2, 3:
                if indexPath.row == 1 && order.taxInfo != nil {     // tax cell
                    var cellHeight: CGFloat = 0
                    if order.taxInfo?.endDate != nil && ( order.taxInfo?.status == "-1" || order.taxInfo?.status == "" ) {
                        cellHeight = kPaymentOptionsRowHeight + 21
                    } else {
                        cellHeight = kPaymentOptionsRowHeight
                    }
                    self.order.tax > kOneInMillion ? cellHeight += validCGFloat(self.order.warehouses.count) * kWarehouseTaxViewHeight : nil
                    return cellHeight
                }
                if (indexPath.row == 1 && order.taxInfo == nil) || (indexPath.row == 2 && order.taxInfo != nil) {   // shipping cell
                    var cellHeight = kPaymentOptionsRowHeight - 17 + validCGFloat(self.order.warehouses.count) * kWarehouseShippingViewHeight
                    if needShippingAccount {
                        if isViaAcountSelected {
                            cellHeight += 75
                        } else {
                            cellHeight += 45
                        }
                    }
                    return cellHeight
                }
            default:
                break
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                //
            } else if indexPath.row == 1 && validDouble(walletInfo.totalAmount) > kOneInMillion {
                let balanceValueButtonTitle = SSTPaymentWalletCell.getBalanceValueButtonTitle(totalAmount: validDouble(walletInfo.totalAmount))
                if SSTPaymentWalletCell.isNeedNewLine(balanceValueButtonTitle: balanceValueButtonTitle, isWalletSelected: self.isWalletSelected) {
                    return 59
                } else {
                    return 44
                }
            } else {
                return SSTBasePayVC.getPaymentOptionCellHeight(tip: getPaymentTypeByIndexPath(indexPath)?.tip)
            }
        }
        return kPaymentOptionsRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
                let cell = loadNib("\(SSTSectionHeadCell.classForCoder())") as! SSTSectionHeadCell
                cell.icon.image = UIImage(named: kPaymentTypeImgName)
                cell.title.text = kPaymentOptionsTitle
                return cell
            } else if indexPath.row == 1 && validDouble(walletInfo.totalAmount) > kOneInMillion {
                return getSSTPaymentWalletCell(indexPath: indexPath)
            } else {
                return getSSTCardInfoCell(indexPath: indexPath)
            }
        }
        return UITableViewCell()
    }
}
