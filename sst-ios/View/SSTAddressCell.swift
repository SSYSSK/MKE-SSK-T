//
//  SSTAddressCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTAddressCell: SSTBaseCell {

    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var companyLabel: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var primaryBtn: UIButton!
    @IBOutlet weak var billingBtn: UIButton!
    @IBOutlet weak var shippingBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var selectAddressIcon: UIImageView!
    
    @IBOutlet weak var companyLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameLabelHeightConstraint: NSLayoutConstraint!
    
    var fromOrderConfirm: Bool?
    
    var setDefaultPrimaryAddressBlock:(() ->Void)?
    var setDefaultBillingAddressBlock:(() ->Void)?
    var setDefaultShippingAddressBlock:(() ->Void)?

    var editAddressBlock:(() ->Void)?
    var deleteAddressBlock:(() ->Void)?

    var info: SSTShippingAddress! {
        didSet {
            if fromOrderConfirm == true {
                selectAddressIcon.isHidden = false
                primaryBtn.isHidden = true
                billingBtn.isHidden = true
                shippingBtn.isHidden = true
                deleteBtn?.removeFromSuperview()
            } else {
                selectAddressIcon?.removeFromSuperview()
            }
            
            if validString(info.companyName).isEmpty {
                companyLabel.removeFromSuperview()
                companyName.removeFromSuperview()
            } else {
                companyLabel.text = "Company"
                companyName.text = info.companyName
                let lineCnt = validInt(validDouble(info.companyName?.sizeByWidth(font: 13, width: 5000).width) / validDouble(kScreenWidth - companyName.x - 15)) + 1
                if lineCnt <= 1 {
                    companyLabelHeightConstraint.constant = 15
                } else {
                    companyLabelHeightConstraint.constant = 33
                }
            }
            
            let userNameText = "\(validString(info.firstName)) \(validString(info.lastName))"
            userName.text = userNameText
            let lineCnt = validInt(validDouble(userNameText.sizeByWidth(font: 13, width: 5000).width) / validDouble(kScreenWidth - userName.x - 15)) + 1
            if lineCnt <= 1 {
                nameLabelHeightConstraint.constant = 15
            } else {
                nameLabelHeightConstraint.constant = 33
            }
            
            addressName.text = info.addressName
            phone.text = validString(info.phone)

            let tmpCountryString = validString(info.countryName) == kUnitedState ? "" : "\n\(validString(info.countryName))"
            address.text = "\(validString(info.apt))\n\(validString(info.city)), \(validString(info.state)) \(validString(info.zip))\(tmpCountryString)"

            if info.isPrimary {
                primaryBtn.layer.borderColor = kPurpleColor.cgColor
                primaryBtn.setTitleColor(kPurpleColor, for: UIControlState())
                primaryBtn.backgroundColor = kPurpleBgClolor
                primaryBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            } else {
                primaryBtn.layer.borderColor = kDarkGaryColor.cgColor
                primaryBtn.setTitleColor(UIColor.darkText, for: UIControlState())
                primaryBtn.backgroundColor = UIColor.clear
                primaryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            }
            
            if info.isBilling {
                billingBtn.layer.borderColor = kPurpleColor.cgColor
                billingBtn.setTitleColor(kPurpleColor, for: UIControlState())
                billingBtn.backgroundColor = kPurpleBgClolor
                billingBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            } else {
                billingBtn.layer.borderColor = kDarkGaryColor.cgColor
                billingBtn.setTitleColor(UIColor.darkText, for: UIControlState())
                billingBtn.backgroundColor = UIColor.clear
                billingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            }
            
            if info.isShipping {
                shippingBtn.layer.borderColor = kPurpleColor.cgColor
                shippingBtn.setTitleColor(kPurpleColor, for: UIControlState())
                shippingBtn.backgroundColor = kPurpleBgClolor
                shippingBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            } else {
                shippingBtn.layer.borderColor = kDarkGaryColor.cgColor
                shippingBtn.setTitleColor(UIColor.darkText, for: UIControlState())
                shippingBtn.backgroundColor = UIColor.clear
                shippingBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            }
            
            if info.isSelected {
                selectAddressIcon?.image = UIImage(named: "icon_choose_sel")
            } else {
                selectAddressIcon?.image = UIImage(named: "icon_choose_normal")
            }
        }
    }
    
    @IBAction func clickedPrimaryAction(_ sender: AnyObject) {
        guard info.isPrimary == false else {
            SSTToastView.showError(kAddressPrimaryAddressText)
            return
        }
        if let block = setDefaultPrimaryAddressBlock {
            block()
        }
    }
    
    @IBAction func clickedBillingAction(_ sender: AnyObject) {
        guard info.isBilling == false else {
            SSTToastView.showError(kAddressBillingAddressText)
            return
        }
        if let block = setDefaultBillingAddressBlock {
            block()
        }
    }
    
    @IBAction func clickedShippingAction(_ sender: AnyObject) {
        guard info.isShipping == false else {
            SSTToastView.showError(kAddressShippingAddressText)
            return
        }
        if let block = setDefaultShippingAddressBlock {
            block()
        }
    }
    
    @IBAction func clickedEditAction(_ sender: AnyObject) {
        if let block = editAddressBlock {
            block()
        }
    }
    
    @IBAction func clickedDeleteAction(_ sender: AnyObject) {
        if let block = deleteAddressBlock {
            block()
        }
    }
    

}
