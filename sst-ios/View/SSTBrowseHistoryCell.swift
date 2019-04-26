//
//  SSTBrowseHistoryCell.swift
//  sst-ios
//
//  Created by Amy on 2016/10/19.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTBrowseHistoryCell: SSTBaseCell {

    @IBOutlet weak var clock: UIImageView!
    @IBOutlet weak var countDownLabel: UILabel!
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var soldOutImg: UIImageView!
    @IBOutlet weak var unavailableImgV: UIImageView!
    
    @IBOutlet weak var countDownImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var oldPrice: UILabel!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var discount: UILabel!
    
    @IBOutlet weak var limView: UIView!
    @IBOutlet weak var precentNumLabel: UILabel!
    
    var deleteHistoryBlock:((_ item: SSTItem) ->Void)?

    var item: SSTItem! {
        didSet {
            if item.isPromoItem {
                clock.isHidden = false
                countDownLabel.isHidden = false
                countDownLabel.text = item.promoCountdownText
                countDownImg.isHidden = false
                limView.isHidden = false
                precentNumLabel.text = "\(item.priceDiscountPercentTextItemDetail)%"
            } else {
                clock.isHidden = true
                countDownLabel.isHidden = true
                countDownImg.isHidden = true
                limView.isHidden = true
                countDownLabel.text = nil
                precentNumLabel.text = ""
            }
            
            productImage.setImage(fileUrl: item.thumbnail, placeholder: kItemDetailPlaceholderImageName)
            productTitle.text = item.name
            oldPrice.text = item.listPrice?.formatC()
            price.text = item.price.formatC()
            
            if validDouble(item.listPrice) - item.price > kOneInMillion {
                line.isHidden = false
                discount.text = "Save \(validDouble(validDouble(item.listPrice) - item.price).formatC())"
            } else {
                line.isHidden = true
                discount.text = ""
            }
            
            soldOutImg.isHidden = item.inStock
            unavailableImgV.isHidden = !item.isUnavailable
        }
    }

    @IBAction func clickedDeleteAction(_ sender: AnyObject) {
        if let block = deleteHistoryBlock {
            block(self.item)
        }
    }
    
}
