//
//  SSTShippingDetailProductCell.swift
//  sst-ios
//
//  Created by Amy on 16/6/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTOrderItemCell: SSTBaseCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var soldOutImgV: UIImageView!
    @IBOutlet weak var unavailableImgV: UIImageView!
    @IBOutlet weak var bottomLineV: UIView!
    
    var orderItem: SSTOrderItem! {
        didSet {
            productImage.setImage(fileUrl: orderItem.thumbnail, placeholder: kItemDetailPlaceholderImageName)
            productName.text = orderItem.name
            productPrice.text = orderItem.price.formatC()
            count.text = "x \(orderItem.qty)"
            soldOutImgV.isHidden = orderItem.inStock
            unavailableImgV.isHidden = !orderItem.isUnavailable
        }
    }
}
