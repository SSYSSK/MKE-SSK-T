//
//  SSTMyAddressVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
//import Async

class SSTMyAddressVC: SSTBaseVC {
    
    var isFromOrderConfirmVC = false
    
    @IBOutlet weak var myTableView: UITableView!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    lazy fileprivate var addressInfo = SSTAddressData()
    
    var titleType = 0 // VC title 1 shipping address,2: billing address ,others: my address
    var chooseAddressBlock:((_ address: SSTShippingAddress) ->Void)?
    
    var addressClicked: SSTShippingAddress?
    var addressClickedSection = -1
    
    var oldAddressCnt: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 170
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        switch titleType {
        case 1:
            self.title = kMoreAddressTitleShipping
        case 2:
            self.title = kMoreAddressTitleBilling
        default:
            self.title = kMoreAddressTitle
        }
        
        addressInfo.delegate = self
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight)
        emptyView.setData(imgName: "icon_address_empty", msg: kNoAddressTip, buttonTitle: "", buttonVisible: false)
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        
        self.refreshView()
    }
    
    func refreshView() {
        SSTProgressHUD.show(view: self.view)
        addressInfo.getAddressList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func refreshAddressInBaseOrderShippingVC() {
        if validBool(self.navigationController?.childViewControllers.last?.isKind(of: SSTBaseOrderShippingVC.classForCoder())) {
            if let block = self.chooseAddressBlock, let tmpAddress = addressClicked {
                block(tmpAddress)
            }
        }
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        SSTProgressHUD.show(view: self.view)
        addressInfo.getAddressList()
    }
    
    @IBAction func addAddressEvent(_ sender: AnyObject) {
        self.performSegueWithIdentifier(.SegueToAddAddressVC, sender: nil)
    }
    
    override func clickedBackBarButton() {
        if chooseAddressBlock != nil && addressClickedSection >= 0 {
            if let tmpAddress = self.addressInfo.addressList.validObjectAtIndex(addressClickedSection) as? SSTShippingAddress {
                self.addressClicked = tmpAddress
                chooseAddressBlock?(tmpAddress)
            }
        }
        _ = self.navigationController?.popViewController(animated: true)
    }
}

// MARK: -- UITableView Delegate

extension SSTMyAddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return addressInfo.addressList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else {
            return 0.1
        }
        return 10.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = loadNib("\(SSTAddressCell.classForCoder())") as? SSTAddressCell {
            
            if let address = addressInfo.addressList.validObjectAtIndex(indexPath.section) as? SSTShippingAddress {
                if addressClicked != nil {
                    if address.id == validString(addressClicked?.id) || address.id == validString(addressClicked?.id) {
                        address.isSelected = true
                        addressClickedSection = indexPath.section
                    } else {
                        address.isSelected = false
                    }
                }
                
                cell.fromOrderConfirm = isFromOrderConfirmVC
                cell.info = address
                
                cell.setDefaultPrimaryAddressBlock = { [weak self] in
                    self?.addressInfo.setDefaultPrimaryAddress(validString(address.id))
                }
                cell.setDefaultBillingAddressBlock = { [weak self] in
                    self?.addressInfo.setDefaultBillingAddress(validString(address.id))
                }
                cell.setDefaultShippingAddressBlock = { [weak self] in
                    self?.addressInfo.setDefaultShippingAddress(validString(address.id))
                }
                cell.editAddressBlock = {
                    self.addressClicked = address
                    self.performSegueWithIdentifier(.SegueToAddressVC, sender:address)
                }
                cell.deleteAddressBlock = { [weak self] in
                    guard address.isPrimary == false else {
                        SSTToastView.showError(kMoreDeleteAddressFailedTip)
                        return
                    }
                    let iconActionSheet: UIAlertController = UIAlertController(title: nil, message: kMoreDeleteAddressTip, preferredStyle: UIAlertControllerStyle.actionSheet)
                    iconActionSheet.addAction(UIAlertAction(title:"Delete", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
                        self?.addressInfo.deleteAddress(validString(address.id))
                    }))
                    
                    iconActionSheet.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler:nil))
                    self?.present(iconActionSheet, animated: true, completion: nil)
                }
            }
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromOrderConfirmVC {
            for address in addressInfo.addressList {
                address.isSelected = false
            }
            
            if let info = self.addressInfo.addressList.validObjectAtIndex(indexPath.section) as? SSTShippingAddress {
                info.isSelected = true
                addressClicked = info
                myTableView.reloadData()
                if let block = self.chooseAddressBlock, let tmpAddress = addressClicked {
                    block(tmpAddress)
                }
                TaskUtil.delayExecuting(0.1, block: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.resignFirstResponder()
    }
}

// MARK: -- Segue delegate

extension SSTMyAddressVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToAddressVC    = "ToEditAddressVC"
        case SegueToAddAddressVC = "ToAddAddressVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case .SegueToAddressVC:
            let destVC = segue.destination as! SSTAddressDetailVC
            destVC.addresses = addressInfo.addressList
            destVC.address = addressClicked
        case .SegueToAddAddressVC:
            let destVC = segue.destination as! SSTAddressDetailVC
            destVC.addresses = addressInfo.addressList
        }
    }
}

// MAKR: -- refreshUI delegate

extension SSTMyAddressVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if self.addressInfo.addressList.count > 0 {
            if oldAddressCnt == 0 && self.addressInfo.addressList.count == 1 && isFromOrderConfirmVC {
                self.addressInfo.addressList[0].isSelected = true
                self.addressClicked = self.addressInfo.addressList[0]
            }
            myTableView.reloadData()
            myTableView.isHidden = false
        } else {
            myTableView.isHidden = true
        }
        emptyView.isHidden = !myTableView.isHidden
        
        self.oldAddressCnt = self.addressInfo.addressList.count
    }
}
