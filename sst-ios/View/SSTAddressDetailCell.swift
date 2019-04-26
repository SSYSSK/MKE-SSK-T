//
//  SSTAddressDetailCell.swift
//  sst-ios
//
//  Created by Amy on 16/8/24.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTAddressDetailCell: SSTBaseCell {

    
    @IBOutlet weak var companyName: UITextView!
    @IBOutlet weak var street: UITextView!
    @IBOutlet weak var addressTitle: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var country: UITextField!
    @IBOutlet weak var state: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var postalCode: UITextField!
    
    var info = SSTShippingAddress() {
        didSet {
            companyName.text = info.companyName
            addressTitle.text = info.addressName
            firstName.text = info.firstName
            lastName.text = info.lastName
            phone.text = info.phone
            city.text = info.city
            state.text = info.state
            country.text = info.countryName
            street.text = info.apt
            postalCode.text = info.zip
            
        }
    }
    
}

extension SSTAddressDetailCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString: NSString = (validString(textField.text) as NSString).replacingCharacters(in: range, with: string) as NSString
        if postalCode.isEditing && toBeString.length > 5 {
            return false
        }
        else if phone.isEditing {
            
            //021-456-8901
            if toBeString.length == 4 && range.length == 0 {
                textField.text = "\(toBeString.substring(to: 3))-\(string)"
                return false
            }
            else if toBeString.length == 8 && range.length == 0 {
                textField.text = "\(toBeString.substring(to: 7))-\(string)"
                return false
            }else if toBeString.length == 13 && range.length == 0 {
                SHAKEPHONE()
                return false
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == country {
            phone.resignFirstResponder()
            //跳转页面，显示国家
//            self.performSegueWithIdentifier(SSTAddressDetailVC.SegueIdentifier.SegueToChooseCountryVC, sender: nil)
            return false
        } else if country.text == "United States" && textField == state {
//            self.performSegueWithIdentifier(SSTAddressDetailVC.SegueIdentifier.SegueToChooseStateVC, sender: nil)
            return false
        }
        return true
    }
}
