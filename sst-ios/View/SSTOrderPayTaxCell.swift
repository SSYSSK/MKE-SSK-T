//
//  SSTOrderPayTaxCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/30.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTOrderPayTaxCell: SSTBaseCell {

    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var taxBtn: UIButton!
    @IBOutlet weak var date: UILabel!
    
    var clickToTaxBlock:(() -> Void)?
    
    func setData(tax: Double,company: String, fee: Double, taxInfo: SSTFreeTaxInfo){
        self.tax.text = tax.formatC()
        //当shipping address 是CA，则根据条件判断是否需要显示过期时间还是提示内容
        if taxInfo.status == "1" {  //1:免税申请成功，则不显示申请信息
            //-1:申请无效
            //0:申请中
            taxBtn.isHidden = true
            date.isHidden = true
        } else  {
            if taxInfo.endDate == nil { //到期时间为空，则显示Tax Exemption（和原来一样）
                taxBtn.setTitle("Tax Exemption", for: UIControlState.normal)
                taxBtn.isHidden  = false
                date.isHidden = true
            } else {
                //到期时间不为空，且没有过期，则显示：Please submit/upload your CA reseller permit by xxxx to obtain CA sales tax exemption
                taxBtn.setTitle("CA tax exemption", for: UIControlState.normal)
                if taxInfo.inGracePeriod == 1 {
                    if taxInfo.status == "-1" || taxInfo.status == "" { //申请状态无效且没有过期，则显示：Please submit/upload your CA reseller permit by xxxx to obtain CA sales tax exemption
                        date.text = "Please submit/upload your CA reseller permit by \(validString(taxInfo.endDate?.formatYYYYMMDD())) to obtain CA sales tax exemption"
                    } else {  //申请审核中(0)且没有过期，则显示到期时间Expiration Date: xxxx（和原来一样)
                        date.text = "Expiration Date: \(validString(taxInfo.endDate?.formatYYYYMMDD()))"
                        date.textAlignment = .right
                    }
                    
                } else {
                    date.text = "Tax Exemption allowance period expired"
                }
                
            }
        }
    }
    
    @IBAction func clickedTaxAction(_ sender: AnyObject) {
        if let block = clickToTaxBlock {
            block()
        }
    }

}
