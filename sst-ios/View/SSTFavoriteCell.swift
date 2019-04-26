//
//  SSTFavoriteCell.swift
//  sst-ios
//
//  Created by Amy on 16/9/13.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTFavoriteCell: SSTBaseCell {

    @IBOutlet weak var clock: UIImageView!
    
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var soldOutImg: UIImageView!
    @IBOutlet weak var unavailableImgV: UIImageView!
    
    @IBOutlet weak var countDownImg: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var oldPrice: StrickoutLabel!
    @IBOutlet weak var discount: UILabel!
    @IBOutlet weak var line: UIView!
    
    @IBOutlet weak var limView: UIView!
    
    @IBOutlet weak var precentNumLabel: UILabel!
    
    @IBOutlet weak var imgViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var oldPriceHeightConstraint: NSLayoutConstraint!
    
    var item: SSTItem! {
        didSet {
            if item.isPromoItem {
                clock.isHidden = false
                countDownLabel.isHidden = false
                countDownLabel.text = item.promoCountdownText
                countDownImg.isHidden = false
                productImage.setImage(fileUrl: validString(item.thumbnail), placeholder: kItemDetailPlaceholderImageName)
                imgViewTopConstraint.constant = 15
                
                limView.isHidden = false
                precentNumLabel.text = item.priceDiscountPercentTextItemDetail
            } else {
                clock.isHidden = true
                countDownLabel.isHidden = true
                countDownLabel.text = ""
                countDownImg.isHidden = true
                productImage.setImage(fileUrl: item.thumbnail, placeholder: kItemDetailPlaceholderImageName)
                imgViewTopConstraint.constant = 10
                
                limView.isHidden = true
                precentNumLabel.text = ""
            }
            
            productTitle.text = item.name
            
            if item.listPrice == nil {
                oldPriceHeightConstraint.constant = 0
                oldPrice.text = ""
                discount.text = ""
                line.isHidden = true
                price.text = item.price.formatC()
            } else {
                oldPriceHeightConstraint.constant = 20
                oldPrice.text = validDouble(item.listPrice).formatC()
                discount.text = " Save \((validDouble(item.listPrice) - validDouble(item.promoItemPrice)).formatC())"
                line.isHidden = false
                price.text = validDouble(item.price).formatC()
            }
            
            soldOutImg.isHidden = item.inStock
            unavailableImgV.isHidden = !item.isUnavailable
        }
    }

    @IBAction func clickedDeleteAction(_ sender: AnyObject) {
        biz.favoriteData.removeItem(item){ (data, error) in
            if error == nil {
                SSTToastView.showSucceed(kFavoriteDeletxText)
            }
        }

    }
    
}
