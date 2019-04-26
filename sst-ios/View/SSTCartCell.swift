//
//  SSTCartCell.swift
//  sst-ios
//
//  Created by Amy on 16/8/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTCartCell: UICollectionViewCell, UITextFieldDelegate {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var unavailableImgV: UIImageView!
    @IBOutlet weak var soldOutImgV: UIImageView!
    
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var oldPrice: StrickoutLabel!
    @IBOutlet weak var savedMoney: UILabel!
    @IBOutlet weak var discountImg: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountInfoView: SSTDiscountsView!
    @IBOutlet weak var promoMaxQtyPerUser: UILabel!
    
    @IBOutlet weak var timeImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var promoNumberLabel: UILabel!
    
    @IBOutlet weak var promoView: UIView!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    @IBOutlet weak var timerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var discountViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var promoViewHeightConstraint: NSLayoutConstraint!
    
    var keyboardDoneButton: UIButton!
    var changeCartClick: (() -> Void)?
    
    var favotiteClick:((_ item:SSTCartItem) -> Void)?
    
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var qtyTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    
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
    
    @IBAction func favoriteEvent(_ sender: Any) {
        if let block = favotiteClick {
            block(item)
        }
    }
    
    func setQtyTFAndButtons() {
        SSTItem.setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton, minQtyAvailable: 1)
    }
    
    internal var item: SSTCartItem! {
        didSet {
            
            if item.promoQty > 0 {
                discountImg.isHidden = false
                promoMaxQtyPerUser.font = UIFont.systemFont(ofSize: 11 * kProkScreenWidth)
                promoMaxQtyPerUser.isHidden = false

                if item.promoCountContained > 0 {
                    promoMaxQtyPerUser.text = String(format: kCartCellDiscountTip, item.promoCountContained, (item.promoCountContained > 1 ? "s" : ""))
                    promoViewHeightConstraint.constant = kCartCellPromoViewHeight
                } else {
                    promoViewHeightConstraint.constant = 0
                }
                
                timeImage.isHidden = false
                timeLabel.isHidden = false
                promoView.isHidden = false
                if validInt64(item.promoCountdown) > 0 {
                    timeLabel.text = item.promoCountdownText
                    timerViewHeightConstraint.constant = kCartCellTimerViewHeight
                } else {
                    timeImage.isHidden = true
                    timeLabel.isHidden = true
                    timerViewHeightConstraint.constant = 0
                }
                
                if item.priceDiscountPercentTextItemDetail.isNotEmpty {
                    promoNumberLabel.text = String(format: "%@%%", item.priceDiscountPercentTextItemDetail)
                    promoView.isHidden = false
                } else {
                    promoView.isHidden = true
                }
            } else {
                promoView.isHidden = true
                timeImage.isHidden = true
                timeLabel.isHidden = true
                timerViewHeightConstraint.constant = 0
                promoViewHeightConstraint.constant = 0
                promoMaxQtyPerUser.isHidden = true
                discountImg.isHidden = true
            }
            
            productImage.setImage(fileUrl: validString(item.thumbnail), placeholder: kItemDetailPlaceholderImageName)
            unavailableImgV.isHidden = item.isUnavailable ? false : true
            soldOutImgV.isHidden = item.inStock
            
            itemPriceLabel.text = "Item Price: \(validString(item.outPrice.formatC()))"
            
            productTitle.text = item.name
            productPrice.text = item.sumFinalPrice.formatC()
            qtyTF.text = "\(item.qty)"
            
            self.setQtyTFAndButtons()
 
            if validString(item.promoId).isNotEmpty {
                let saveMoney = item.sumOriginalPrice - item.sumFinalPrice
                if saveMoney > 0 {
                    oldPrice.isHidden = false
                    savedMoney.isHidden = false
                    savedMoney.text = "Save \(saveMoney.formatC())"
                } else {
                    oldPrice.isHidden = true
                    savedMoney.isHidden = true
                    savedMoney.text = "Save \(0.formatC())"
                }
                
                savedMoney.font = UIFont.systemFont(ofSize: 12 * kProkScreenWidth)
            } else {
                oldPrice.isHidden = true
                savedMoney.isHidden = true
            }
            
            if item.sumOriginalPrice - item.sumFinalPrice > kOneInMillion {
                oldPrice.text = item.sumOriginalPrice.formatC()
            } else {
                oldPrice.text = ""
            }
            
            let saveMoney = item.sumOriginalPrice - item.sumFinalPrice
            if saveMoney > 0 {
                oldPrice.isHidden = false
                savedMoney.isHidden = false
                savedMoney.text = "Save \(saveMoney.formatC())"
            } else {
                oldPrice.isHidden = true
                savedMoney.isHidden = true
                savedMoney.text = "Save \(0.formatC())"
            }
        }
    }
    
    @IBAction func removeEvent(_ sender: AnyObject) {
        SSTProgressHUD.show(view: self.viewController()?.view)
        biz.cart.removeItems([item.id]) { (data, error) in
            if error != nil {
                SSTToastView.showError(kCartRemoveFailedText)
            }
        }
    }
    
    @IBAction func plusEvent(_ sender: AnyObject) {
        SSTItem.clickedAddButton(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
    
    @IBAction func reduceEvent(_ sender: AnyObject) {
        SSTItem.clickedMinusButton(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton, minQtyAvailable: 1)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return SSTItem.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        SSTItem.updateQty(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton, minQtyAvailable: 1)
    }
}

