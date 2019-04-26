//
//  SSTHomeDailyDealsItem.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/3/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTHomeDailyDealsItemV: UIView {
    
    @IBOutlet weak var offerExpiredLabel: UILabel!
    @IBOutlet weak var precentLabel: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var savePriceLabel: StrickoutLabel!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SSTHomeDailyDealsItemV.tappedImg(_:)))
        imgV.addGestureRecognizer(tap)
        imgV.layer.masksToBounds = true
        imgV.layer.cornerRadius = 10
    }
    
    var item: SSTItem! {
        didSet {
            imgV.setImage(fileUrl: validString(item.dailyDealImg), placeholder: kItemDetailPlaceholderImageName)
            priceLabel.text = item.promoPrice.formatC()
            nameLabel.text = item.name
            savePriceLabel.text = item.listPrice?.formatC()
            precentLabel.text = item.priceDiscountPercentTextItemDetail
            offerExpiredLabel.isHidden = item.isPromoItem ? true : false
        }
    }
    
    @objc func tappedImg(_ sender: UITapGestureRecognizer) {
        printDebug("tapped...")
    }
    
}
