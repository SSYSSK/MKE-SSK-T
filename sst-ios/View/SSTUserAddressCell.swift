//
//  SSTUserAddressCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTUserAddressCell: SSTBaseCell {

    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var message: UILabel!
    
    func setData(_ addressInfo: SSTShippingAddress?) {
        if addressInfo?.id != nil {
            message.isHidden = true
            companyName.text = validString(addressInfo?.companyName)
            
            if let info = addressInfo {
                let tmpCountryString = validString(info.countryName) == kUnitedState ? "" : "\n\(validString(info.countryName))"
                address.text = "\(validString(info.apt))\n\(validString(info.city)), \(validString(info.state)) \(validString(info.zip))\(tmpCountryString)"
            }
        } else {
            message.isHidden = false
        }
        companyName.isHidden = !message.isHidden
        address.isHidden = !message.isHidden
    }
}
