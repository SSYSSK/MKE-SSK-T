//
//  SSTSearchResultView.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/21/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

enum SSTViewFrom: String {
    case fromDeals = "fromDeals"
    case fromOther = "fromOther"
}

let kItemViewAddButtonWH: CGFloat = 50
let kItemViewOffViewWH: CGFloat = 40 * kProkScreenWidth

let kItemNameLabelColor: UIColor = RGBA(88, g: 88, b: 88, a: 1)

class SSTSearchResultView: SSTItemBaseView {
    
    // price info
    
    var priceLabel : UILabel!
    var listPriceLabel: StrickoutLabel!
    
    var saveMoneyLabel: UILabel!
    
    // cart button info
    
    var addButton : UIButton!
    var qtyTF: UITextField!
    var minusButton : UIButton!
    var soldoutBtn : UIButton!
    
    func initPriceView() {
        priceLabel = UILabel(frame: CGRect(x: 20, y:50, width: self.frame.height - 40, height: self.frame.height - 40))
        priceLabel.font = UIFont.boldSystemFont(ofSize: 15)
        priceLabel.textColor = UIColor.black
        self.addSubview(priceLabel)
        
        saveMoneyLabel = UILabel(frame: CGRect(x: priceLabel.frame.maxX + 1 ,  y: imgV.frame.origin.y + 30, width: self.frame.width - 40, height: 15))
        saveMoneyLabel.sizeToFit()
        saveMoneyLabel.textColor = RGBA(111, g: 115, b: 245, a: 1)
        saveMoneyLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(saveMoneyLabel)
        
        listPriceLabel = StrickoutLabel(frame: CGRect(x: 20, y:50, width: self.frame.height - 40, height: self.frame.height - 40))
        listPriceLabel.font = UIFont.systemFont(ofSize: 12)
        listPriceLabel.textColor = RGBA(188, g: 188, b: 188, a: 1)
        listPriceLabel.isHidden = true
        self.addSubview(listPriceLabel)
        

    }
    
    func initCartButtonView() {
        minusButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        minusButton.addTarget(self, action: #selector(SSTSearchResultView.deleteEvent(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(minusButton)
        
        addButton = UIButton(frame: CGRect(x: 17*kProkScreenWidth, y: 0, width: 40, height: 40))
        addButton.addTarget(self, action: #selector(SSTSearchResultView.addEvent(_:)), for: UIControlEvents.touchUpInside)
        self.addSubview(addButton)
        
        qtyTF = UITextField(frame: CGRect(x: 20 , y: 2, width: 20, height: 20))
        qtyTF.textAlignment = NSTextAlignment.center
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
        qtyTF.tag = 009
        qtyTF.textAlignment = .center
        self.addSubview(qtyTF)
        
        soldoutBtn = UIButton(frame: CGRect(x: 20, y: priceLabel.frame.maxY, width: self.frame.width - 40, height: 20))
        soldoutBtn.setTitle("Get Stock Reminder", for: UIControlState())
        soldoutBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
        soldoutBtn.backgroundColor = kLightGrayColor
        soldoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        soldoutBtn.layer.cornerRadius = 2
        soldoutBtn.addTarget(self, action: #selector(SSTSearchResultView.soldoutBtnEvent), for: UIControlEvents.touchUpInside)
        self.addSubview(soldoutBtn)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initPriceView()
        initCartButtonView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setItemInfo() {
        super.setItemInfo()
        
        self.setItemPriceInfo()
        self.setItemCartButtonInfo()
    }
    
    func setQtyTFAndButtons() {
        SSTItem.setQtyTFAndButtons(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
    
    func setItemPriceInfo() {
        priceLabel.text = item.price.formatC()
        
        switch viewFrom {
        case .fromDeals:
            
            priceLabel.text = validString(item.promoPrice.formatC())
            
            listPriceLabel.isHidden = false
            listPriceLabel.text = item.listPrice?.formatC()
            listPriceLabel.sizeToFit()
            
            saveMoneyLabel.text = " Save \((validDouble(item.listPrice) - validDouble(item.promoItemPrice)).formatC())"
            saveMoneyLabel.isHidden = false
            
        case .fromOther:
            if item.isPromoItem && validInt64(item.promoCountdown) > 0 {
                
                if let liprice = item.listPrice {
                    priceLabel.isHidden = false
                    
                    priceLabel.sizeToFit()
                    priceLabel.text = validString(item.promoItemPrice?.formatC())
                    
                    saveMoneyLabel.text = " Save \((validDouble(item.listPrice) - validDouble(item.promoItemPrice)).formatC())"
                    
                    listPriceLabel.isHidden = false
                    listPriceLabel.text = liprice.formatC()
                    listPriceLabel.sizeToFit()
                }
                saveMoneyLabel.isHidden = false
            } else {
                listPriceLabel.text = ""
                listPriceLabel.isHidden = true
                saveMoneyLabel.isHidden = true
            }
        }
    }
    
    func setItemCartButtonInfo() {
        addButton.setImage(UIImage(named: "icon_plus"), for: UIControlState.normal)
        addButton.setImage(UIImage(named: "icon_plusH"), for: UIControlState.highlighted)
        
        minusButton.setImage(UIImage(named: "icon_reduce"), for: UIControlState.normal)
        minusButton.setImage(UIImage(named: "icon_reduceH"), for: UIControlState.highlighted)
        minusButton.setImage(UIImage(named: "icon_reduceNo"), for: UIControlState.disabled)
        
        if let cartItem = biz.cart.findItem(item.id) {
            qtyTF.textColor = RGBA(111, g: 115, b: 245, a: 1)
            qtyTF.text = "\(cartItem.qty)"
        } else {
            qtyTF.textColor = UIColor.black
            qtyTF.text = "0"
        }
        
        soldoutBtn.isHidden = item.inStock
        minusButton.isHidden = !item.inStock
        qtyTF.isHidden = !item.inStock
        addButton.isHidden = !item.inStock
        if !item.inStock {
            if item.isStockReminded == true {
                soldoutBtn.setTitle("Reminder Subscribed", for: UIControlState())
                soldoutBtn.setTitleColor(kPurpleColor, for: UIControlState())
            } else {
                soldoutBtn.setTitle("Get Stock Reminder", for: UIControlState())
                soldoutBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
            }
        }
        
        setQtyTFAndButtons()
    }
    
    override func setViewFrame(layout: SearchResultLayoutStyle = .grid) {
        super.setViewFrame(layout: layout)
        
        self.setViewFramePriceView(layout: layout)
        self.setViewFrameCartButtonView(layout: layout)
    }
    
    func setViewFramePriceView(layout: SearchResultLayoutStyle = .grid) {
        if layout == SearchResultLayoutStyle.grid {
            
            if viewFrom == .fromDeals || validDouble(item?.listPrice) - validDouble(item?.price) > kOneInMillion {
                listPriceLabel.isHidden = false
                saveMoneyLabel.isHidden = false
            } else {
                listPriceLabel.isHidden = true
                saveMoneyLabel.isHidden = true
            }
            
            listPriceLabel.frame = CGRect(x: 15, y: imgV.frame.maxY + 38, width: self.frame.width - 40, height: 15)
            listPriceLabel.sizeToFit()
            
            saveMoneyLabel.frame = CGRect(x: listPriceLabel.frame.maxX + 1 , y: listPriceLabel.y, width: self.frame.width - 40, height: 15)
            saveMoneyLabel.sizeToFit()
            
            priceLabel.frame = CGRect(x: 15, y: imgV.frame.maxY + 55, width: self.frame.width - 40, height: 15)
        } else {
            
            listPriceLabel.frame = CGRect(x: imgV.frame.width + 40, y: self.height * 0.42, width: self.frame.width - 40, height: 15)
            listPriceLabel.sizeToFit()
            
            saveMoneyLabel.frame = CGRect(x: listPriceLabel.frame.maxX + 1, y: listPriceLabel.y, width: self.frame.width - 40, height: 15)
            saveMoneyLabel.sizeToFit()
            
            priceLabel.frame = CGRect(x: imgV.frame.width + 40, y: self.height * 0.58, width: self.frame.width - 40, height: 15)
        }
        
        if nameLabel.numberOfLines == 2 {
            listPriceLabel.isHidden = false
            saveMoneyLabel.isHidden = false
        } else {
            listPriceLabel.isHidden = true
            saveMoneyLabel.isHidden = true
        }
    }
    
    func setViewFrameCartButtonView(layout: SearchResultLayoutStyle = .grid) {
        if layout == SearchResultLayoutStyle.grid {
            minusButton.frame = CGRect(x: 0, y: imgV.frame.maxY + 62, width: kItemViewAddButtonWH, height: kItemViewAddButtonWH)
            qtyTF.frame = CGRect(x: minusButton.frame.maxX, y: minusButton.y + 15, width: self.frame.width - kItemViewAddButtonWH * 2, height: 20)
            addButton.frame = CGRect(x: self.frame.width - kItemViewAddButtonWH, y: minusButton.y, width: kItemViewAddButtonWH, height: kItemViewAddButtonWH)
            
            soldoutBtn.frame = CGRect(x: 15, y: imgV.frame.maxY + 75, width: self.width - 30, height: 23)
        } else {
            minusButton.frame = CGRect(x: imgV.frame.width + 27, y: imgV.frame.maxY - 20, width: kItemViewAddButtonWH, height: kItemViewAddButtonWH)
            qtyTF.frame = CGRect(x: minusButton.frame.maxX, y: minusButton.y + 15, width: self.frame.height - 60, height: 20)
            addButton.frame = CGRect(x:qtyTF.frame.maxX, y: minusButton.y, width: kItemViewAddButtonWH, height: kItemViewAddButtonWH)
            
            let soldoutBtnWdith = max(addButton.center.x - minusButton.x, validString(soldoutBtn.titleLabel?.text).sizeByWidth(font: 12).width + 8)
            soldoutBtn.frame = CGRect(x: imgV.frame.width + 40, y: imgV.frame.maxY - 7, width: soldoutBtnWdith, height: 23)
        }
    }
    
    @objc func soldoutBtnEvent() {
        guard item.id.isNotEmpty else {
            return
        }
        SSTProgressHUD.show(view: self.viewController()?.view)
        if item.isStockReminded == true { // 取消订阅
            SSTItemData.cancelStockNotification(item.id, callback: { (message) in
                SSTProgressHUD.dismiss(view: self.soldoutBtn.viewController()?.view)
                if validInt(message) == 200 {
                    self.soldoutBtn.setTitle("Get Stock Reminder", for: UIControlState())
                    self.soldoutBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
                    SSTToastView.showSucceed(kCancelStockReminderSuccessText)
                } else {
                    SSTToastView.showError(validString(message))
                }
            })
        } else { // 订阅
            SSTItemData.saveStockNotifications(item.id, callback: { (message) in
                SSTProgressHUD.dismiss(view: self.soldoutBtn.viewController()?.view)
                if validInt(message) == 200 {
                    self.soldoutBtn.setTitle("Reminder Subscribed", for: UIControlState())
                    self.soldoutBtn.setTitleColor(kPurpleColor, for: UIControlState())
                    SSTToastView.showSucceed(kStockReminderSuccessText)
                } else {
                    SSTToastView.showError(validString(message))
                }
            })
        }
    }

    @objc func addEvent(_ button: UIButton) {
        SSTItem.clickedAddButton(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton, block: {
            var origin = self.imgV.frame.origin
            var tmpV = self.imgV as UIView
            for _ in 0 ... 100 {
                if let superV = tmpV.superview {
                    if superV.isKind(of: UIScrollView.classForCoder()) {
                        let scrollView = superV as! UIScrollView
                        origin.x = origin.x + superV.frame.origin.x - scrollView.contentOffset.x
                        origin.y = origin.y + superV.frame.origin.y - scrollView.contentOffset.y
                    } else {
                        origin.x = origin.x + superV.frame.origin.x
                        origin.y = origin.y + superV.frame.origin.y
                    }
                    tmpV = superV
                } else {
                    break
                }
            }
            
            let imgViewForFlyingToCart = UIImageView(frame: CGRect(origin: origin, size: self.imgV.frame.size))
            imgViewForFlyingToCart.image = self.imgV.image
            self.window?.addSubview(imgViewForFlyingToCart)
            UIView.animate(withDuration: 0.6, animations: {
                let xxx = kScreenWidth / 5 * 3 + kScreenWidth / 5 / 2
                imgViewForFlyingToCart.frame = CGRect(x: xxx, y: kScreenHeight - 30 - kScreenBottomSpaceHeight, width: 5, height: 5)
            }) { (Bool) in
                imgViewForFlyingToCart.removeFromSuperview()
            }
        })
    }
    
    @objc func deleteEvent(_ button:UIButton) {
        SSTItem.clickedMinusButton(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return SSTItem.textField(textField, shouldChangeCharactersIn: range, replacementString: string)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        SSTItem.updateQty(item: item, qtyTF: qtyTF, minusButton: minusButton, addButton: addButton)
    }
}

