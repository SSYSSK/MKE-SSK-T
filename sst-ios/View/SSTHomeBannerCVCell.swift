//
//  SSTHomeBannerCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/3/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTHomeBannerCVCell: UICollectionViewCell {
    
    var itemClick: ((_ obj: AnyObject) -> Void)?
    
    var banners: [SSTBanner]! {
        didSet {
            for ind in 0 ..< banners.count {
                if let tBanner = banners.validObjectAtIndex(ind) as? SSTBanner {
                    let originX = CGFloat(ind) * (kScreenWidth - 1) / 2 + CGFloat(ind) * 1
                    let imageView = UIImageView(frame: CGRect(x: originX, y: 4, width: (kScreenWidth - 1) / 2, height: 63))
                    
                    imageView.setImage(fileUrl: validString(tBanner.bannerFile), placeholder: "banner\(ind)")
                    imageView.tag = ind
                    let tap = UITapGestureRecognizer(target: self, action: #selector(SSTHomeBannerCVCell.clickedViewEvent))
                    imageView.isUserInteractionEnabled = true
                    imageView.addGestureRecognizer(tap)
                    self.addSubview(imageView)
                    
                    let flagImgV = UIImageView(frame: CGRect(x: originX + 20, y: 1, width: 40, height: 18))
                    flagImgV.setImage(fileUrl: validString(tBanner.flagIcon), placeholder: ind == 0 ? "home_hot" : "home_new")
                    self.addSubview(flagImgV)
                }
            }
        }
    }
    
    @objc func clickedViewEvent(_ tap: UITapGestureRecognizer) {
        if let item = banners.validObjectAtIndex(validInt(tap.view?.tag)) {
            itemClick?(item)
        }
    }

}
