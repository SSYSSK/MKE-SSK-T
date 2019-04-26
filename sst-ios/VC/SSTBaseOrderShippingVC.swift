//
//  SSTBaseOrderShippingVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 8/8/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kDefaultShippingAddress           = "defaultShippingAddress"
let kDefaultBillingAddress            = "defaultBillingAddress"
let kShippingCompany                  = "shippingCostVos"
let kLastMergableTargetOrder          = "lastMergableTargetOrder"
let kLastMergableOrderShippingCompany = "lastMergableTargetOrderShippingName"
let kShippingDetailTip                = "shippingDetailTip"

let kChooseWarehouseRsp               = "chooseWarehouseRspVo"
let kComplexOrderInfo                 = "complexOrderVo"
let kAllWarehouseInfo                 = "allWarehouseInfoVos"
let kWarehouseForProduct              = "usableWarehouseForProductVos"
let kShippingCompanyForWarehouse      = "usableShippingCompanyForWarehouseVos"

class SSTBaseOrderShippingVC: SSTBaseVC {
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var payView: UIView!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var oldTotalLabel: UILabel!
    @IBOutlet weak var itemCntLabel: UILabel!
    
    var lastMergableOrderShippingCompanyName: String?
    var mergableOrder: SSTOrder?
    var billingAddress:  SSTShippingAddress?
    var shippingAddress: SSTShippingAddress?
    
    var sections = 3    // 所有的section个数
    
    var order: SSTOrder? {
        didSet {
            /*
             本页面按照实际需求分多个section
             1.billing address
             2.shipping address
             3.shipping from +（多仓库的时候需要显示或者隐藏的提示信息。Dear customer...）
             4.多仓库（如果有多个仓库则显示多个）
             5.订单提示（如果订单信息中返回了提示，则显示 90 exchange...）
             */
            self.sections = 3 + validInt(self.order?.warehouses.count) + (canAddShippingAccount ? 1 : 0) + (validBool(self.shippingDetailTip?.isNotEmpty) ? 1 : 0)
        }
    }
    var warehouses: [SSTWarehouse]?                     // all warehouses
    var seletedWarehouse: SSTOrderWarehouse?            // 当前选择的仓库
    
    var shippingDetailTip: String?
    
    fileprivate let kSectionHeadImgNames = [kBillingAddressImgName, kShippingAddressImgName, kShippingDeliveryImgName]
    fileprivate let kSectionHeadTitles = [kOrderBillingAddress, kOrderShippingAddress, kOrderDeliveryMethods]
    
    var shippingCostInfoClicked: SSTShippingCostInfo?
    var shippingAccountCell: SSTShippingAccountCell?
    
    var isShowWHInfo = false //是否显示提示信息，提醒用户可以选择多仓库
    var itemsTotal: Double {
        get {
            if validString(self.order?.id).isEmpty {
                return biz.cart.orderItemsTotal
            } else {
                return validDouble(self.order?.orderFinalTotal)
            }
        }
    }
    
    var finalTotal: Double {
        get {
            var total: Double = 0
            for ind in 0 ..< validArray(self.order?.warehouses).count {
                if let wh = self.order?.warehouses.validObjectAtIndex(ind) as? SSTOrderWarehouse {
                    let tWH = SSTWarehouse.findWarehouse(id: validString(wh.warehouseId), warehouses: validArray(self.warehouses) as! [SSTWarehouse])
                    let seletedShippingInfo = getSeletedShippingInfo(shippingCompanyId: validString(wh.shippingCompanyId),shippingCostInfos: (tWH?.shippingCostInfos)! )
                    total += wh.totalWithoutTax + seletedShippingInfo.costPrice * (1 + wh.taxRate)
                    wh.finalTax = wh.taxWithoutProduct + seletedShippingInfo.costPrice * wh.taxRate
                }
            }
            return total
        }
    }
    
    var oldFinalTotal: Double {
        get {
            return finalTotal + validDouble(self.order?.discount)
        }
    }
    
    var canAddShippingAccount: Bool {
        get {
            var willAddToLastOrder = false
            if validString(mergableOrder?.id).isNotEmpty && ( validInt(self.shippingCostInfoClicked?.companyId) == 17 || validInt(self.shippingCostInfoClicked?.companyId) == 18 ) {
                willAddToLastOrder = true
            }
            if validString(self.shippingCostInfoClicked?.metaName) == "FEDEX" && validDouble(self.shippingCostInfoClicked?.costPrice) > kOneInMillion && !willAddToLastOrder {
                return true
            }
            return false
        }
    }
    
    var shippingAccount: String {
        get {
            if canAddShippingAccount && validBool(shippingAccountCell?.selectButton.isSelected) {
                return validString(shippingAccountCell?.fedexAccountTF.text).trim()
            }
            return ""
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
        
        NotificationCenter.default.addObserver(self, selector:#selector(timerAlarm), name: kEveryOneSecondNotification, object: nil)
        
        self.fetchInfo()
    }
    
    //获取当前选择的物流公司信息
    func getSeletedShippingInfo( shippingCompanyId: String, shippingCostInfos: [SSTShippingCostInfo]) -> SSTShippingCostInfo {
        let spInfo = SSTShippingCostInfo()
        if shippingCompanyId.isEmpty {
            return spInfo
        }
        for ind in 0 ..< validInt(shippingCostInfos.count) {
            let tInfo = shippingCostInfos[ind] as SSTShippingCostInfo
            if tInfo.shippingCompanyId == shippingCompanyId {
                return tInfo
            }
        }
        return spInfo
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func timerAlarm() {
        for wh in validArray(self.warehouses) as! [SSTWarehouse] {
            for sci in validArray(wh.shippingCostInfos) as! [SSTShippingCostInfo] {
                sci.cutOffTimeCountDown = validInt64(sci.cutOffTimeCountDown) - kItemPromoCountdownUnit
            }
        }
        
        for cell in self.myTableView.visibleCells {
            if cell.isKind(of: SSTShippingInfoCell.classForCoder()) {
                (cell as? SSTShippingInfoCell)?.refreshCountdownView()
            }
        }
    }
    
    func fetchInfo() {}
    
    func refreshPayView() {
        self.totalLabel.text = finalTotal.formatC()
        if oldFinalTotal - finalTotal > kOneInMillion {
            self.oldTotalLabel.isHidden = false
            self.itemCntLabel.isHidden = false
            self.oldTotalLabel.text = oldFinalTotal.formatC()
            self.itemCntLabel.text = "Save \((oldFinalTotal - finalTotal).formatC())"
        } else {
            self.oldTotalLabel.isHidden = true
            self.oldTotalLabel.text = ""
            self.itemCntLabel.text = ""
        }
        payView.isHidden = false
    }
    
    func doAfterFetchInfo(_ data: Any?, _ error:Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if error == nil {
            var dict = validDictionary(data)
            
            if dict[kDefaultBillingAddress] != nil, let tBillingAddr = SSTShippingAddress(JSON: validDictionary(dict[kDefaultBillingAddress])) {
                self.billingAddress = tBillingAddr
            }
            if dict[kDefaultShippingAddress] != nil,  let tShippingAddress = SSTShippingAddress(JSON: validDictionary(dict[kDefaultShippingAddress])) {
                self.shippingAddress = tShippingAddress
            }
            
            self.lastMergableOrderShippingCompanyName = validString(dict[kLastMergableOrderShippingCompany])
            self.shippingDetailTip = validString(dict[kShippingDetailTip]).trim()
            
            var rspDict = dict
            if !validDictionary(dict[kChooseWarehouseRsp]).isEmpty {
                rspDict = validDictionary(validDictionary(data)[kChooseWarehouseRsp])
            }
            if let tOrder = SSTOrder(JSON: validDictionary(rspDict[kComplexOrderInfo])) {
                self.order = tOrder
            }
            if !validArray(rspDict[kWarehouseForProduct]).isEmpty {
                self.setWarehouses(dict: rspDict)
            }
            self.updateWarehousesInventoryAndShippingCostInfos(dict: rspDict)
            self.isShowWHInfo = validInt(self.order?.warehouses.count) > 1 ? true : false //是否显示多仓库的提示，当只有一个仓库的时候不显示提示信息，有多个仓库的时候提示用可以使用多仓库，点击删除按钮，则删除此信息
            
            self.refreshPayView()
            self.myTableView.reloadData()
        } else {
            if validBool(self.shippingAddress?.id?.isNotEmpty) {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func setWarehouses(dict: Dictionary<String,Any>) {
        var tWarehouses = [SSTWarehouse]()
        for pwDict in validArray(dict[kWarehouseForProduct]) {
            for wDict in validArray(validDictionary(pwDict)["warehouseDisplayInfoVos"]) {
                var wh = SSTWarehouse.findWarehouse(id: validString(validDictionary(wDict)[kWarehouseId]), warehouses: tWarehouses)
                if wh == nil {
                    wh = SSTWarehouse(JSON: validDictionary(wDict))
                    tWarehouses.append(wh!)
                }
                if wh != nil {
                    wh?.productInventory[validString(validDictionary(pwDict)["productId"])] = validInt(validDictionary(wDict)[kWarehouseInventory])
                }
            }
        }
        self.warehouses = tWarehouses
    }
    
    func updateWarehousesInventoryAndShippingCostInfos(dict: Dictionary<String, Any>) {
        for wh in validArray(self.warehouses) as! [SSTWarehouse] {
            for scwDict in validArray(dict[kShippingCompanyForWarehouse]) {
                if validString(validDictionary(scwDict)[kWarehouseId]) == validString(wh.warehouseId) {
                    var tShippingCostInfos = [SSTShippingCostInfo]()
                    for scDict in validArray(validDictionary(scwDict)["shippingCostVos"]) {
                        if let tShippingCostInfo = SSTShippingCostInfo(JSON: validDictionary(scDict)) {
                            tShippingCostInfos.append(tShippingCostInfo)
                        }
                    }
                    wh.shippingCostInfos = tShippingCostInfos
                }
            }
        }
    }
    
    func getMergableOrder(_ shippingAddressId: String) {
        fetchInfo()
    }
    
    func validWhenContinue() -> Bool {
        guard shippingAddress?.id != nil else {
            SSTToastView.showError(kOrderShippingAddressTip)
            return false
        }
        guard billingAddress?.id != nil else {
            SSTToastView.showError(kOrderBillingAddressTip)
            return false
        }
        return true
    }
    
    func toWarehouseItemsVC() {
        self.performSegueWithIdentifier(SegueIdentifier.SegueToWarehouseItemsVC, sender: nil)
    }
    
    func getShippingCostInfoInWarehourse(section: Int, row: Int) -> SSTShippingCostInfo? {
        if let wh = self.order?.warehouses.validObjectAtIndex(section) as? SSTOrderWarehouse {
            let tWH = SSTWarehouse.findWarehouse(id: validString(wh.warehouseId), warehouses: validArray(self.warehouses) as! [SSTWarehouse])
            if let scInfo = tWH?.shippingCostInfos?.validObjectAtIndex(row) as? SSTShippingCostInfo {
                return scInfo
            }
        }
        return nil
    }
    
    func getShippingCostInfoByWarehouse(warehouse: SSTOrderWarehouse) -> SSTShippingCostInfo? {
        let tWH = SSTWarehouse.findWarehouse(id: validString(warehouse.warehouseId), warehouses: validArray(self.warehouses) as! [SSTWarehouse])
        for sci in validArray(tWH?.shippingCostInfos) as! [SSTShippingCostInfo] {
            if sci.shippingCompanyId == warehouse.shippingCompanyId {
                return sci
            }
        }
        return nil
    }
    
    func moveItemToAnotherOrderWarehouse(item: SSTOrderItem, fromWarehouseId: String, toWarehouseId: String, callback: @escaping RequestCallBack) {
        var itmCnt = 0
        for wh in validArray(order?.warehouses) as! [SSTOrderWarehouse] {
            itmCnt += wh.orderItems.count
        }
        if toWarehouseId.isEmpty && itmCnt == 1 {
            let mAC = UIAlertController(title: "", message: kEmptyAllWharehouseItemsTip, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
                if let cartItm = biz.cart.findItem(item.id) {
                    biz.cart.updateItem(cartItm, addingQty: -cartItm.qty)
                }
                self.navigationController?.popToRootViewController(animated: true)
            })
            mAC.addAction(cancelAction)
            mAC.addAction(okAction)
            getTopVC()?.present(mAC, animated: true, completion: nil)
        } else {
            if let tWh = SSTOrderWarehouse.findWarehouse(id: fromWarehouseId, warehouses: validArray(self.order?.warehouses) as! [SSTOrderWarehouse]) {
                (tWh as? SSTOrderWarehouse)?.removeItem(id: item.id)
            }
            
            if toWarehouseId != "" {
                if let tWh = SSTOrderWarehouse.findWarehouse(id: toWarehouseId, warehouses: validArray(self.order?.warehouses) as! [SSTOrderWarehouse]) {
                    (tWh as? SSTOrderWarehouse)?.addItem(orderItem: item)
                } else {
                    let nWh = SSTOrderWarehouse()
                    nWh.warehouseId = toWarehouseId
                    nWh.addItem(orderItem: item)
                    self.order?.warehouses.append(nWh)
                }
            }
            
            SSTProgressHUD.show(view: getTopVC()?.view)
            self.order?.moveItemToAnotherOrderWarehouse(shippingAddressCountryCode: validString(shippingAddress?.countryCode), shippingAddressStateCode: validString(shippingAddress?.stateCode)) { data, error in
//                SSTProgressHUD.dismiss(view: getTopVC()?.view)
                self.doAfterFetchInfo(data, error)
                if let topVC = getTopVC() as? SSTWarehouseItemsVC {
                    self.seletedWarehouse = SSTOrderWarehouse.findWarehouse(id: validString(self.seletedWarehouse?.warehouseId), warehouses: validArray(self.order?.warehouses) as! [SSTWarehouse]) as? SSTOrderWarehouse
                    topVC.warehourse = self.seletedWarehouse
                    topVC.usableWarehouses = self.warehouses
                }
                callback(data, error)
            }
        }
    }
}

// MARK: -- UITableViewDelegate, UITableViewDataSource

extension SSTBaseOrderShippingVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section < 2 {   // billing address and shipping adress
            return 2
        } else if section == 2 {
            return 1
        } else if section < 3 + validInt(self.order?.warehouses.count) {
            if let wh = self.order?.warehouses.validObjectAtIndex(section - 3) as? SSTWarehouse {
                let tWH = SSTWarehouse.findWarehouse(id: validString(wh.warehouseId), warehouses: validArray(self.warehouses) as! [SSTWarehouse])
                return 1 + validInt(tWH?.shippingCostInfos?.count)
            }
            return 0
        } else if canAddShippingAccount {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0  {
            return 0.1
        } else if section == 3 {
            return isShowWHInfo ? 50 : 0.1
        } else {
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 3 && isShowWHInfo {
            let noticeInfoView = loadNib("\(SSTWarehouseInfoView.classForCoder())") as! SSTWarehouseInfoView
            noticeInfoView.deleteNoticeBlock = { [weak self] in
                self?.isShowWHInfo = false
                self?.myTableView.reloadData()
            }
            return noticeInfoView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == tableView.numberOfSections - 1 {
            return 10
        }
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section < 3 {   // billing address and shipping adress
            if indexPath.row == 0 {
                let cell = loadNib("\(SSTSectionHeadCell.classForCoder())") as! SSTSectionHeadCell
                cell.icon.image = UIImage(named:"\(kSectionHeadImgNames[indexPath.section])")
                cell.title.text = "\(kSectionHeadTitles[indexPath.section])"
                return cell
            } else {
                let cell = loadNib("\(SSTUserAddressCell.classForCoder())") as! SSTUserAddressCell
                indexPath.section == 0 ? cell.setData(billingAddress): cell.setData(shippingAddress)
                return cell
            }
        } else if indexPath.section < 3 + validInt(self.order?.warehouses.count) {
            if indexPath.row == 0 {
                let cell = loadNib("\(SSTWarehouseHeadInfoCell.classForCoder())") as! SSTWarehouseHeadInfoCell
                if let owh = self.order?.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse {
                    cell.info = owh
                }
                return cell
            } else {
                let cell = loadNib("\(SSTShippingInfoCell.classForCoder())") as! SSTShippingInfoCell
                cell.lastShippingStr = lastMergableOrderShippingCompanyName
                cell.lastOrderId = mergableOrder?.id
                
                let wh = self.order?.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse
                if let scInfo = self.getShippingCostInfoInWarehourse(section: indexPath.section - 3, row: indexPath.row - 1) {
                    scInfo.isSelect = scInfo.shippingCompanyId == validString(wh?.shippingCompanyId)
                    cell.info = scInfo
                }
                
                return cell
            }
        } else if canAddShippingAccount {
            let cell = loadNib("\(SSTShippingAccountCell.classForCoder())") as! SSTShippingAccountCell
            self.shippingAccountCell = cell
            cell.companyNameLabel.text = self.shippingCostInfoClicked?.name
            cell.selectButtonClick = { isSelect in
                self.refreshPayView()
            }
            return cell
        } else {
            let cell = loadNib("\(SSTShippingTipCell.classForCoder())") as! SSTShippingTipCell
            (cell.viewWithTag(1001) as? UILabel)?.text = self.shippingDetailTip
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 || indexPath.section == 1 {
            let addressListVC = loadVC(controllerName: "\(SSTMyAddressVC.classForCoder())", storyboardName: kStoryBoard_More) as! SSTMyAddressVC
            if indexPath.section == 0 {
                addressListVC.addressClicked = billingAddress
            } else {
                addressListVC.addressClicked = shippingAddress
            }
            addressListVC.isFromOrderConfirmVC = true
            addressListVC.titleType = indexPath.section == 0 ? 2 : 1
            self.navigationController?.pushViewController(addressListVC, animated: true)
            addressListVC.chooseAddressBlock = { address in
                if address.id != nil {
                    if validString(self.kSectionHeadTitles.validObjectAtIndex(indexPath.section)) == kOrderBillingAddress {
                        self.billingAddress = address
                        if address.id == self.shippingAddress?.id {
                            self.shippingAddress = address
                        }
                        self.myTableView.reloadData()
                    } else {
                        self.shippingCostInfoClicked = nil
                        self.shippingAddress = address
                        if address.id == self.billingAddress?.id {
                            self.billingAddress = address
                        }
                        self.getMergableOrder(validString(address.id))
                    }
                }
            }
        } else if indexPath.section >= 3 && indexPath.section < 3 + validInt(self.order?.warehouses.count) {
            if indexPath.row == 0 {     // 选择各个仓库，进入产品详情界面，可对产品进行修改仓库的操作
                if self.shippingAddress == nil {
                    SSTToastView.showError(kOrderShippingAddressTip)
                    return
                }
                seletedWarehouse = self.order?.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse
                self.toWarehouseItemsVC()
            } else {                    // 更换物流公司
                if let scInfo = self.getShippingCostInfoInWarehourse(section: indexPath.section - 3, row: indexPath.row - 1) {
                    let wh = self.order?.warehouses.validObjectAtIndex(indexPath.section - 3) as? SSTOrderWarehouse
                    wh?.shippingCompanyId = scInfo.shippingCompanyId
                    self.refreshPayView()
                    self.myTableView.reloadData()
                }
            }
        }
    }
    
}

// MARK: -- refreshUI delegate

extension SSTBaseOrderShippingVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if validString(data) == "ShippingCompanyList" {
            refreshPayView()
            if myTableView.numberOfSections > 2 {
                myTableView.reloadSections(IndexSet(integer: 2), with: .none)
            }
            SSTProgressHUD.dismiss(view: self.view)
        }
    }
}

// MARK: -- segue delegate

extension SSTBaseOrderShippingVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToPaymentOptionsVC = "toPaymentOptionsVC"
        case SegueToWarehouseItemsVC = "toWarehouseItemsVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .SegueToPaymentOptionsVC:
            
            let paymentVC = segue.destination as! SSTBasePayVC
            
            order?.shippingAddress = shippingAddress
            order?.billingAddress = billingAddress
            order?.shippingCostInfo = shippingCostInfoClicked
            order?.shippingCompanyName = shippingCostInfoClicked?.name
            
            if mergableOrder?.id != nil {
                if validInt(self.shippingCostInfoClicked?.companyId) == 17 || validInt(self.shippingCostInfoClicked?.companyId) == 18 {
                    paymentVC.lastMergableOrder = self.mergableOrder
                }
            }
            
            paymentVC.order = order
            paymentVC.shippingAddress = shippingAddress
            paymentVC.billingAddress = billingAddress
            paymentVC.shippingcostInfo = shippingCostInfoClicked
            paymentVC.shippingAccount = self.shippingAccount
        case .SegueToWarehouseItemsVC:
            let itemsVC = segue.destination as! SSTWarehouseItemsVC
            itemsVC.order = self.order
            itemsVC.warehourse = self.seletedWarehouse
            itemsVC.usableWarehouses = self.warehouses
        }
    }
}
