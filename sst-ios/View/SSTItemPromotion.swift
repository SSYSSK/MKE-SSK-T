//
//  SSTItemDetailShippingPromotion.swift
//  sst-ios
//
//  Created by Amy on 2016/12/16.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTItemPromotion: SSTBaseCell {

    @IBOutlet weak var shippingImg: UIImageView!
    @IBOutlet weak var shippingInfo: UILabel!
    
    var info: SSTFreeShippingInfo! {
        didSet {
            shippingInfo.text = info.tip
            shippingImg.setImage(fileUrl:validString(info.logo), placeholder: "icon_item_default")
        }
    }

}
