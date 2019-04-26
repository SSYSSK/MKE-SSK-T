//
//  SSTShippingAccountCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/8/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTShippingAccountCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var fedexAccountTF: UITextField!
    
    var selectButtonClick: ((_ isSelectViaAccount: Bool) -> Void)?
    
    @IBAction func clickedSelectButton(_ sender: Any) {
        selectButton.isSelected = !selectButton.isSelected
        if selectButton.isSelected {
            fedexAccountTF.isEnabled = true
        } else {
            fedexAccountTF.isEnabled = false
        }
        selectButtonClick?(selectButton.isSelected)
    }
    
    @IBAction func clickedAccountButton(_ sender: Any) {
        clickedSelectButton(sender)
    }
    
    // MARK: -- UITextFieldDelegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        selectButtonClick?(selectButton.isSelected)
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        selectButtonClick?(selectButton.isSelected)
        textField.resignFirstResponder()
        return true
    }
}
