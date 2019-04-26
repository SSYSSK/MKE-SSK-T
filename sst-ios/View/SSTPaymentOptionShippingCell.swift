//
//  SSTPaymentOptionShippingCell.swift
//  sst-ios
//
//  Created by Amy on 2017/2/14.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTPaymentOptionShippingCell: SSTBaseCell {

    @IBOutlet weak var shippingCompanyName: UILabel!
    @IBOutlet weak var shippingFee: UILabel!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var fedexAccountTF: UITextField!
    @IBOutlet weak var originShippingFeeLabel: UILabel!
    
    @IBOutlet weak var warehousesView: UIView!
    
    @IBOutlet weak var selectButtonBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var shippingTextLabel: UILabel!
    @IBOutlet weak var shippingFeeLeadingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var selectOverTextButton: UIButton!
    
    var selectButtonClick: ((_ isSelectViaAccount: Bool) -> Void)?
    var isSelect: Bool?
    
    func setShippingAccountUI(needAccount: Bool, isSelected: Bool) {
        isSelect = isSelected
        if needAccount {
            selectButton.isHidden = false
            accountLabel.isHidden = false
        } else {
            selectButton.isHidden = true
            accountLabel.isHidden = true
        }
        
        selectButton.isSelected = isSelected
        fedexAccountTF.isHidden = !isSelected
        selectButtonBottomConstraint.constant = isSelected ? -40 : -10
        selectOverTextButton.isEnabled = needAccount
    }
    
    @IBAction func clickedSelectButton(_ sender: Any) {
        isSelect = !validBool(isSelect)
        selectButtonClick?(validBool(isSelect))
    }
    
    @IBAction func clickedAccountButton(_ sender: Any) {
        clickedSelectButton(sender)
    }
    
    var warehouses: [SSTWarehouse]? {
        didSet {
            for ind in 0 ..< validInt(warehouses?.count) {
                let whView = loadNib("\(SSTWarehouseShippingView.classForCoder())") as! SSTWarehouseShippingView
                whView.frame = CGRect(x: 0, y: validCGFloat(ind) * kWarehouseShippingViewHeight, width: kScreenWidth - kOrderDetailInfoLeadingImageWidth, height: kWarehouseShippingViewHeight)
                if let wh = warehouses?.validObjectAtIndex(ind) as? SSTOrderWarehouse {
                    whView.setInfo(warehouseName: validString(wh.warehouseName), shippingFee: validDouble(wh.shippingFinalTotal), originShippingFee: validDouble(wh.nativeShippingTotal), shippingCompanyName: validString(wh.shippingCompanyName))
                }
                self.warehousesView.addSubview(whView)
            }
        }
    }
    
    func setDataForOrderDetail(shippingFee: Double, origialFee: Double, warehouses: [SSTWarehouse]?) {
        self.shippingTextLabel.textColor = RGBA(102, g: 102, b: 102, a: 1)
        self.shippingTextLabel.font = UIFont.systemFont(ofSize: 12)
        self.shippingFee.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.shippingFeeLeadingConstraint.constant = kOrderDetailInfoLeadingImageWidth
        self.setShippingAccountUI(needAccount: false, isSelected: false)
        self.shippingFee.text = shippingFee.formatC()
        self.originShippingFeeLabel.text = origialFee > shippingFee ? origialFee.formatC() : ""
        self.warehouses = warehouses
        //nativeShippingTotal 原shipping总价
        //warehouse shippingfinal total ,不划线 里面的nativeshipppingtotal是划线了
        
    }
}
