//
//  SSTItemDetailsInfoCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTItemDetailsInfoCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var qtyTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var listPriceLabel: UILabel!
    @IBOutlet weak var clickView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        qtyTF.keyboardType = UIKeyboardType.numberPad
        let inputV = SSTInputAccessoryView()
        inputV.buttonClick = { [weak self] in
            if let tTF = self?.qtyTF {
                tTF.resignFirstResponder()
            }
        }
        qtyTF.inputAccessoryView = inputV
        qtyTF.returnKeyType = .done
        qtyTF.delegate = self
    }
    
    var item: SSTItem! {
        didSet {
            nameL.text = validString(item.name)
            priceLabel.text = validDouble(item.price).formatC()
            SSTItem.setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
            clickView.isHidden = !item.canAddToCart
        }
    }
    
    func setQtyTFAndButtons() {
        SSTItem.setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
    
    @IBAction func clickedMinusButton(_ sender: AnyObject) {
        SSTItem.clickedMinusButton(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
    
    @IBAction func clickedPlusButton(_ sender: AnyObject) {
        (self.viewController() as? SSTItemDetailVC)?.clickedAddtoCartButton(sender)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return SSTItem.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        SSTItem.updateQty(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
}
