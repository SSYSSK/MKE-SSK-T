//
//  SSTOrderDetailHeadCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/22.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTOrderDetailHeadCell: SSTBaseCell {

    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet weak var notice: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var statusImage: UIImageView!
    
    func setData(_ statusValue: String, Email: String){
        
        orderStatus.text = "Your order is \(statusValue)"
        let attributedStr = NSMutableAttributedString(string: validString(orderStatus.text))
        let tmpStr = validString(orderStatus.text) as NSString
        let range = tmpStr.range(of: "Your order is")
        attributedStr.addAttributes(
            [   NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)],
                range: NSMakeRange(0,range.length)
        )
        orderStatus.attributedText = attributedStr
        self.email.text = Email
    }
}
