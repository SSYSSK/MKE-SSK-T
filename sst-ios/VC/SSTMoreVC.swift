//
//  SSTMoreVC.swift
//  sst-ios
//
//  Created by Amy on 16/8/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kMoreTableViewSectionHeight: CGFloat = 6 * kProkScreenHeight
let kMoreTableViewY: CGFloat = kIsIphoneX ? -44 : -20

class SSTMoreVC: SSTBaseVC, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var orderData = SSTOrderData()
    var balanceOrderData = SSTBalanceOrderData()    // 欠款订单
    var applyCOD = SSTApplyCod()
    var addressData = SSTAddressData()
    
    var defaultShippingAddress: SSTShippingAddress?
    
    var isChangeCellHeight: Bool = false            // true: 需要显示tax,则改变cell高度
    var isShowTaxBtn: Bool {                        // true: 显示More 按钮
        get {
            if biz.user.isLogined && validString(gGlobalConfigs.freeTaxSwitch) == "0" && defaultShippingAddress?.stateCode == "CA" {
                return true
            } else {
                return false
            }
        }
    }
    var isShowBalanceOrder: Bool = false            // true: 显示balace order 按钮
    
    var contactMsgRedDotImgView: UIImageView?
    
    enum CellName: Int {
        case Avatar = 0,Order,Profile,Discount,ContactUS,Setting
    }
    
    var isLoginVCShowing = false
    
    fileprivate var webTitle = ""
    fileprivate var webUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 45
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        orderData.delegate = self
        addressData.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if getTopVC()?.navigationController == nil || validBool(getTopVC()?.navigationController?.childViewControllers.first?.isKind(of: SSTMoreVC.classForCoder())) {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        super.viewWillAppear(animated)
        
        refreshView()
        
        SSTContactData.getStatus { (data, error) in
            if error == nil {
                if validBool(validDictionary(data)[kContactHasNew]) == true {
                    self.contactMsgRedDotImgView?.isHidden = false
                } else {
                    self.contactMsgRedDotImgView?.isHidden = true
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !isLoginVCShowing {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        super.viewWillDisappear(animated)
    }
    
    func refreshView() {
        if biz.user.isLogined {
            orderData.getOrderNumbers()
            addressData.getDefaultShippingAddress()
        } else {
            orderData.resetOrderNumbers()
            isShowBalanceOrder = false
        }
        
        if self.tableView != nil {
            if self.tableView.numberOfSections > CellName.Avatar.rawValue {
                self.tableView.reloadSections([CellName.Avatar.rawValue], with: .none)
            }
        }
    }
    
    func refreshProfileCell() {
        if self.tableView != nil {
            if self.tableView.numberOfSections > CellName.Profile.rawValue {
                self.tableView.reloadSections([CellName.Profile.rawValue], with: .none)
            }
        }
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        refreshView()
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        refreshView()
    }
    
    @IBAction func clickedNaviToLoginEvent(_ sender: AnyObject) {
        if biz.user.isLogined == false {
            self.SegueToLoginVC()
        }
    }
    
    fileprivate func SegueToLoginVC() {
        presentLoginVC { (data, error) in
            if error != nil {
                showToastOnlyForDEV("\(validString(error))")
            }
        }
    }
    
    @IBAction func clickedOrderEvents(_ sender: AnyObject) {
        guard biz.user.isLogined == true else {
            presentLoginVC({ (data, error) in
                if biz.user.isLogined {
                    self.clickedOrderEvents(sender)
                }
            })
            return
        }
        performSegueWithIdentifier(.SegueToOrderVC, sender: sender)
    }
    
    func clickedProfileEvents(profileTitle: String) {
        if profileTitle == "Payment & Delivery" {
            self.webTitle = "Payment & Delivery"
            self.webUrl = kBaseURLString + "h5/delivery.h5"
            performSegueWithIdentifier(.toWeb, sender: nil)
            return
        } else if profileTitle == "Return Policy" {
            self.webTitle = "Return Policy"
            self.webUrl = kBaseURLString + "h5/returnArticle.h5?articleId=11267"
            performSegueWithIdentifier(.toWeb, sender: nil)
            return
        } else if profileTitle == "Privacy Policy" {
            self.webTitle = "Privacy Policy"
            self.webUrl = kBaseURLString + "h5/returnArticle.h5?articleId=11265"
            performSegueWithIdentifier(.toWeb, sender: nil)
            return
        } else if profileTitle == "Terms of Service" {
            self.webTitle = "Terms of Service"
            self.webUrl = kBaseURLString + "h5/returnArticle.h5?articleId=11264"
            performSegueWithIdentifier(.toWeb, sender: nil)
            return
        } else if profileTitle == "F.A.Q" {
            self.webTitle = "F.A.Q"
            self.webUrl = kBaseURLString + "h5/returnArticle.h5?articleId=11266"
            performSegueWithIdentifier(.toWeb, sender: nil)
            return
        }
        
        guard biz.user.isLogined == true else {
            presentLoginVC({ (data, error) in
                if biz.user.isLogined {
                    self.clickedProfileEvents(profileTitle: profileTitle)
                }
            })
            return
        }
        
        if profileTitle == "Address" {
            performSegueWithIdentifier(.SegueToAddressVC, sender: nil)
        } else if profileTitle == "C.O.D." {
            performSegueWithIdentifier(.SegueToCODVC, sender: nil)
        } else if profileTitle == "Wallet" {
            performSegueWithIdentifier(.SegueToWalletVC, sender: nil)
        } else if profileTitle == "Tax Exemption" {
            performSegueWithIdentifier(.SegueToTAXVC, sender: nil)
        } else if profileTitle == "Favorite" {
            performSegueWithIdentifier(.SegueToFavoriteVC, sender: nil)
        } else if profileTitle == "Recently Viewed" {
            performSegueWithIdentifier(.SegueToRecentlyVC, sender: nil)
        } else if profileTitle == "Security" {
            performSegueWithIdentifier(.SegueToSafetyVC, sender: nil)
        }
    }

    // MARK: -- UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.section == CellName.Avatar.rawValue {
          let cell = tableView.dequeueReusableCell(withIdentifier: "SSTAvatarCell") as! SSTMoreAvatarCell
            if biz.user.isLogined {
                cell.firstName.isHidden = false
                cell.userID.isHidden = false
                cell.firstName.text = "Hi, " + validString(biz.user.firstName)
                cell.userID.text = "" // "ID:" + validString(biz.user.id)
            } else {
                cell.firstName.isHidden = true
                cell.userID.isHidden = true
            }
            cell.loginBtn.isHidden = !cell.firstName.isHidden
            cell.clickedLoginBlock = { [weak self] in
                self?.SegueToLoginVC()
            }
            return cell
        } else if indexPath.section == CellName.Order.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SSTMoreOrderCell") as! SSTMoreOrderCell
            cell.hasBalanceOrder = isShowBalanceOrder
            cell.orderdata = orderData
            cell.clickedOrderBlock = { [weak self] (sender) in
                guard biz.user.isLogined == true else {
                    presentLoginVC({ (data, error) in
                        if biz.user.isLogined {
                            self?.clickedOrderEvents(sender)
                        }
                    })
                    return
                }
                self?.performSegueWithIdentifier(.SegueToOrderVC, sender: sender)
            }
            cell.clickedBalanceOrderBlock = { [weak self] (sender) in
                self?.performSegueWithIdentifier(.SegueToBalanceOrerVC, sender: sender)
            }
            return cell
        } else if indexPath.section == CellName.Profile.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SSTMoreProfileCell") as! SSTMoreProfileCell
            cell.applyInfo = applyCOD
            cell.setData(shouldShowTaxView: isShowTaxBtn)
            cell.setArrawImage(isDown: isChangeCellHeight)
            cell.clickedProfileBlock = { [weak self] (title) in
                self?.clickedProfileEvents(profileTitle: title)
            }
            cell.clickedMoreBtnBlock = { (shouldChange) in
                self.isChangeCellHeight = shouldChange
                self.tableView.reloadData()
            }
            return cell
        } else if indexPath.section == CellName.Discount.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SSTMoreDiscountCell") {
                return cell
            }
        } else if indexPath.section == CellName.ContactUS.rawValue {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SSTMoreContactCell") {
                contactMsgRedDotImgView = cell.viewWithTag(1002) as? UIImageView
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SSTMoreSettingCell") {
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0.01
        }
        return kMoreTableViewSectionHeight
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            return kMoreTableViewSectionHeight
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if kIsIphoneX {
                return 90 + 24
            } else {
                return 90
            }
        case 1:
            return 28 + kScreenWidth / 4 * 0.55 + 44 + (isShowBalanceOrder ? 35 : 0)
        case 2:
            return 45 + kScreenWidth / 4 * (isChangeCellHeight ? 3 : 2)
        default:
            return 39
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        switch indexPath.section {
        case CellName.Discount.rawValue:
            guard biz.user.isLogined == true else {
                presentLoginVC({ [weak self] (data, error) in
                    if biz.user.isLogined {
                        self?.performSegueWithIdentifier(.SegueToDiscountVC, sender: nil)
                    }
                })
                return
            }
            performSegueWithIdentifier(.SegueToDiscountVC, sender: nil)
        case CellName.ContactUS.rawValue:
            if biz.user.isLogined {
                performSegueWithIdentifier(.SegueToContactSST, sender: nil)
            } else {
                performSegueWithIdentifier(.SegueToContactVC, sender: nil)
            }
        case CellName.Setting.rawValue:
            performSegueWithIdentifier(.SegueToSettingVC, sender: nil)
        default:
            break
        }
    }
}

// MARK: -- segue delegate

extension SSTMoreVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToBalanceOrerVC  = "ToBalanceOrderVC"
        case SegueToOrderVC         = "ToOrderListVC"
        case SegueToAddressVC       = "ToAddressVC"
        case SegueToWalletVC        = "ToWalletVC"
        case SegueToSafetyVC        = "ToInformationSafetyVC"
        case SegueToFavoriteVC      = "ToFavoriteVC"
        case SegueToPaymentVC       = "ToPaymentVC"
        case SegueToRecentlyVC      = "ToRecenlyVC"
        case SegueToHelpVC          = "ToHelpVC"
        case SegueToSettingVC       = "ToSettingVC"
        case SegueToDiscountVC      = "ToDiscountVC"
        case SegueToCODVC           = "ToCODVC"
        case SegueToTAXVC           = "ToTaxVC"
        case SegueToContactVC       = "toContactUs"
        case SegueToContactSST      = "toContactSST"
        case toWeb                  = "toWeb"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        isLoginVCShowing = false
        
        switch segueIdentifierForSegue(segue) {
        case .SegueToBalanceOrerVC:
            let destVC = segue.destination as! SSTBalanceOrderListVC
            destVC.balanceOrderData = balanceOrderData
        case .SegueToOrderVC:
            let destVC = segue.destination as! SSTOrderVC
            if let button = sender as? UIButton {
                destVC.orderType = button.tag - 100
            }
//        case .SegueToAddressVC:
//            let _ = segue.destination as! SSTMyAddressVC
//        case .SegueToWalletVC:
//            let _ = segue.destination as! SSTWalletVC
//        case .SegueToSafetyVC:
//            let _ = segue.destination as! SSTInformationSafetyVC
//        case .SegueToFavoriteVC:
//            let _ = segue.destination as! SSTFavoriteVC
//        case .SegueToPaymentVC:
//            let _ = segue.destination as! SSTPaymentVC
//        case .SegueToRecentlyVC:
//            let _ = segue.destination as! SSTRecentlyViewedVC
//        case .SegueToHelpVC:
//            let _ = segue.destination as! SSTHelpTVC
//        case .SegueToSettingVC:
//            let _ = segue.destination as! SSTSettingVC
//        case .SegueToDiscountVC:
//            let _ = segue.destination as! SSTDiscountDetailVC
//        case .SegueToCODVC:
//            let _ = segue.destination as! SSTCODVC
//        case .SegueToTAXVC:
//            let _ = segue.destination as! SSTTaxVC
//        case .SegueToContactVC:
//            let _ = segue.destination as! SSTContactUsVC
        case .toWeb:
            let destVC = segue.destination as! SSTWebVC
            destVC.webTitle = self.webTitle
            destVC.webUrl = self.webUrl
        default:
            break
        }
    }
}

extension SSTMoreVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        if (data as? SSTOrderData) != nil {
            orderData = data as! SSTOrderData
            if tableView.numberOfSections > CellName.Order.rawValue {
                tableView.reloadSections([CellName.Order.rawValue], with: .none)
            }
        } else if (data as? SSTApplyCod) != nil {
            applyCOD = data as! SSTApplyCod
        } else if (data as? SSTShippingAddress) != nil {
            self.defaultShippingAddress = data as? SSTShippingAddress
            self.refreshProfileCell()
        } else if (data as? SSTBalanceOrderData) != nil {
            balanceOrderData = data as! SSTBalanceOrderData
            isShowBalanceOrder = balanceOrderData.hasBalanceOrder
        }
    }
}
