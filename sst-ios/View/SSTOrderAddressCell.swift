//
//  SSTOrderAddressCell.swift
//  sst-ios
//
//  Created by Amy on 2016/11/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTOrderAddressCell: SSTBaseCell {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var telephone: UILabel!
    @IBOutlet weak var addressName: UILabel!
    @IBOutlet weak var address: UILabel!
    
    var addressInfo: SSTShippingAddress? {
        didSet {
            if let addressI = addressInfo {
                name.text = "\(validString(addressI.firstName)) \(validString(addressI.lastName))"
                telephone.text = addressI.phone
                
                let tmpCountryString = validString(addressI.countryName) == kUnitedState ? "" : "\n\(validString(addressI.countryName))"
                address.text = "\(validString(addressI.apt))\n\(validString(addressI.city)), \(validString(addressI.state)) \(validString(addressI.zip))\(tmpCountryString)"
            }
        }
    }
}
