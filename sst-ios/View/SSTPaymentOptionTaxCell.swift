//
//  SSTPaymentOptionTaxCell.swift
//  sst-ios
//
//  Created by Amy on 2017/2/14.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kPaymentOptionTaxMsgLabelWidth: CGFloat = kScreenWidth - (27 + 65 + 15)

let kWarehouseTaxViewHeight: CGFloat = 30

class SSTPaymentOptionTaxCell: SSTBaseCell {

    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var applyTaxBtn: UIButton!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var warehouseView: UIView!
    
    @IBOutlet weak var taxTextLabel: UILabel!
    @IBOutlet weak var taxLabelLeadingConstraint: NSLayoutConstraint!
    
    var clickToTaxBlock:(() -> Void)?

    func setData(tax: Double, taxInfo: SSTFreeTaxInfo?) {
        
        self.applyTaxBtn.isHidden = true
        self.date.isHidden = true
        
        self.tax.text = tax.formatC()
       
        //当shipping address 是CA，则根据条件判断是否需要显示过期时间还是提示内容
        if taxInfo == nil || taxInfo?.status == "1" {  //1:免税申请成功，则不显示申请信息
                                            //-1:申请无效
                                            //0:申请中
            applyTaxBtn.isHidden = true
            date.isHidden = true
            date.removeFromSuperview()
        } else {
            if taxInfo?.endDate == nil { //到期时间为空，则显示Tax Exemption（和原来一样）
                applyTaxBtn.setTitle("Tax Exemption", for: UIControlState.normal)
                applyTaxBtn.isHidden  = false
                date.isHidden = true
                date.removeFromSuperview()
            } else {
                //到期时间不为空，且没有过期，则显示：Please submit/upload your CA reseller permit by xxxx to obtain CA sales tax exemption
                applyTaxBtn.setTitle("CA tax exemption", for: UIControlState.normal)
                if taxInfo?.inGracePeriod == 1 {
                    if taxInfo?.status == "-1" || taxInfo?.status == "" { //申请状态无效且没有过期，则显示：Please submit/upload your CA reseller permit by xxxx to obtain CA sales tax exemption
                        date.text = "Please submit/upload your CA reseller permit by \(validString(taxInfo?.endDate?.formatYYYYMMDD())) to obtain CA sales tax exemption"
                    } else {  //申请审核中(0)且没有过期，则显示到期时间Expiration Date: xxxx（和原来一样)
                        date.text = "Expiration Date: \(validString(taxInfo?.endDate?.formatYYYYMMDD()))"
                    }
                } else {
                    date.text = "Tax Exemption allowance period expired"
                }
                applyTaxBtn.isHidden = false
                date.isHidden = false
            }
        }
    }
 
    @IBAction func clickedTaxExemptionButton(_ sender: AnyObject) {
        clickToTaxBlock?()
    }
    
    var warehouses: [SSTWarehouse]? {
        didSet {
            for ind in 0 ..< validInt(warehouses?.count) {
                let whView = loadNib("\(SSTWarehouseTaxView.classForCoder())") as! SSTWarehouseTaxView
                whView.frame = CGRect(x: 0, y: validCGFloat(ind) * kWarehouseTaxViewHeight, width: kScreenWidth - kOrderDetailInfoLeadingImageWidth, height: kWarehouseTaxViewHeight)
                if let wh = self.warehouses?.validObjectAtIndex(ind) as? SSTOrderWarehouse {
                    whView.setInfo(warehouseName: validString(wh.warehouseName), taxFee: validDouble(wh.orderTax))
                }
                self.warehouseView.addSubview(whView)
            }
        }
    }
    
    func setDataForOrderDetail(tax: Double, warehouses: [SSTWarehouse]?) {
        self.date.removeFromSuperview()
        self.taxTextLabel.textColor = RGBA(102, g: 102, b: 102, a: 1)
        self.taxTextLabel.font = UIFont.systemFont(ofSize: 12)
        self.tax.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        self.taxLabelLeadingConstraint.constant = kOrderDetailInfoLeadingImageWidth
        self.taxTextLabel.text = "Order Tax"
        self.setData(tax: tax, taxInfo: nil)
        //如果order tax > 0,则显示各仓库的tax 信息，否则不显示
        if validDouble(tax) > kOneInMillion {
            self.warehouses = warehouses
        }
    }
}
