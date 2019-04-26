//
//  SSTItemSlideCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/7.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTItemSlideCell: SSTScrollPageCell {

    @IBOutlet weak var promeView: UIView!
    @IBOutlet weak var savePrecent: UILabel!
    @IBOutlet weak var timeImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var limImageView: UIImageView!
    @IBOutlet weak var soldOutImg: UIImageView!
    @IBOutlet weak var unavailableImgV: UIImageView!
    
    func refreshCountdown() {
        if self.item.isPromoItem && validInt64(item.promoCountdown) > 0 {
            timeLabel.text = "Deal ends in \(item.promoCountdownText)"
        } else {
            timeImageView.isHidden = true
            timeLabel.isHidden = true
        }
    }
    
    var item : SSTItem! {
        didSet {
            
            setParas(item.images, itemWidth: kScreenWidth, itemHeight: kScreenWidth, placeholder: kItemDetailPlaceholderImageName)
            
            if item.isPromoItem && validInt64(item.promoCountdown) > 0 {
                timeLabel.text = "Deal ends in \(item.promoCountdownText)"
                timeImageView.isHidden = true
                timeLabel.isHidden = false
                limImageView.isHidden = false
                
                savePrecent.text = item.priceDiscountPercentTextItemDetail
                promeView.isHidden = false
            } else {
                timeLabel.text =  ""
                timeImageView.isHidden = true
                timeLabel.isHidden = true
                limImageView.isHidden = true
                promeView.isHidden = true
            }
            
            soldOutImg.isHidden = item.inStock
            unavailableImgV.isHidden = !item.isUnavailable
        }
    }
}
