//
//  SSTItemBaseView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/20/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

enum SearchResultLayoutStyle {
    case list
    case grid
}

class SSTItemBaseView: UIView, UITextFieldDelegate {
    
    var viewFrom: SSTViewFrom = .fromOther
    
    var imgV: UIImageView!
    var soldoutImgV : UIImageView!
    var nameLabel: UILabel!
    
    var promoView : UIView!
    var promoBgImgV : UIImageView!
    var promoPercentValueLabel : UILabel!
    var promoTextLabel : UILabel!
    
    var timeImgV : UIImageView!
    var timeCountdownLabel : UILabel!
    var timeExpiredLabel : UILabel!
    
    var kImgViewWidth: CGFloat {
        get {
            return self.height - 132
        }
    }
    
    var layout: SearchResultLayoutStyle? {
        didSet {
            setViewFrame(layout: layout!)
        }
    }
    
    var item: SSTItem! {
        didSet {
            self.setItemInfo()
            self.setViewFrame(layout: self.layout == nil ? SearchResultLayoutStyle.grid : self.layout!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.white
        
        imgV = UIImageView(frame: CGRect(x: 20, y: 20, width: self.frame.height - 40, height: self.frame.height - 40))
        self.addSubview(imgV)
        
        nameLabel = UILabel(frame: CGRect(x: 20, y: 20, width: self.frame.height - 40, height: self.frame.height - 40))
        nameLabel.numberOfLines = 2
        nameLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        nameLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight(rawValue: 0))
        nameLabel.textColor = kItemNameLabelColor
        self.addSubview(nameLabel)
        
        soldoutImgV = UIImageView(frame: CGRect(x: 20, y: 20, width: imgV.width / 2, height: imgV.width / 2))
        soldoutImgV.image = UIImage(named: "icon_soldOut")
        soldoutImgV.isHidden = true
        self.addSubview(soldoutImgV)
        
        promoBgImgV = UIImageView(frame: CGRect(x: self.frame.width - 45, y: 0, width: 45, height: 45))
        promoBgImgV.image = UIImage(named: "promoImage")
        promoBgImgV.isHidden = true
        promoBgImgV.alpha = 0.9
        self.addSubview(promoBgImgV)
        
        promoView = UIView(frame: promoBgImgV.frame)
        promoView.backgroundColor = UIColor.clear
        self.addSubview(promoView)
        
        promoPercentValueLabel = UILabel(frame: CGRect(x: 3, y: 9, width: 24, height: 15))
        promoPercentValueLabel.textColor = UIColor.white
        promoPercentValueLabel.textAlignment = NSTextAlignment.center
        promoPercentValueLabel.font = UIFont.boldSystemFont(ofSize: 13)
        promoPercentValueLabel.minimumScaleFactor = 0.5
        promoPercentValueLabel.adjustsFontSizeToFitWidth = true
        promoView.addSubview(promoPercentValueLabel)
        
        promoTextLabel = UILabel(frame: CGRect(x:0, y: promoView.height / 2 + 2, width: promoView.width, height: 15))
        promoTextLabel.textAlignment = NSTextAlignment.center
        promoTextLabel.textColor = UIColor.white
        promoTextLabel.font = UIFont.systemFont(ofSize: 12)
        promoTextLabel.text = "OFF"
        promoView.addSubview(promoTextLabel)
        
        timeImgV = UIImageView(frame: CGRect(x: 5, y: 4 * kProkScreenWidth, width: 13, height: 13))
        timeImgV.image = UIImage(named: "icon_countDown")
        timeImgV.isHidden = true
        self.addSubview(timeImgV)
        
        timeCountdownLabel = UILabel(frame: CGRect(x: timeImgV.frame.maxX + 5, y: 2, width: kScreenWidth, height: 15))
        timeCountdownLabel.font = UIFont.systemFont(ofSize: 11)
        timeCountdownLabel.text = ""
        timeCountdownLabel.tag = 008
        timeCountdownLabel.isHidden = true
        timeCountdownLabel.textColor = RGBA(36, g: 153, b: 146, a: 1)
        timeCountdownLabel.textAlignment = .left
        self.addSubview(timeCountdownLabel)
        
        timeExpiredLabel = UILabel(frame:  CGRect(x: 5, y: 4, width: 150, height: 15))
        timeExpiredLabel.textColor = UIColor.red
        timeExpiredLabel.tag = 1010
        timeExpiredLabel.text = ""
        timeExpiredLabel.font = UIFont.systemFont(ofSize: 12)
        self.addSubview(timeExpiredLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setItemInfo() {
        imgV.setImage(fileUrl: item.thumbnail, placeholder: kItemDetailPlaceholderImageName)
        nameLabel.text = "\(validString(item.name))"
        soldoutImgV.isHidden = item.inStock
        
        switch viewFrom {
        case .fromDeals:
            if item.isPromoItem {
                timeImgV.isHidden = false
                timeCountdownLabel.isHidden = false
                timeCountdownLabel.text = item.promoCountdownText
                timeExpiredLabel.isHidden = true
            } else {
                timeImgV.isHidden = true
                timeCountdownLabel.isHidden = true
                timeExpiredLabel.isHidden = false
                timeExpiredLabel.text = kItemOfferHasExpired
            }
            
            promoView.isHidden = false
            promoBgImgV.isHidden = false
            promoPercentValueLabel.text = "\(item.priceDiscountPercentTextItemDetail)%"
            
        case .fromOther:
            if item.isPromoItem && validInt64(item.promoCountdown) > 0 {
                
                if item.listPrice != nil {
                    promoView.isHidden = false
                    promoPercentValueLabel.text = "\(item.priceDiscountPercentTextItemDetail)%"
                }
                if validInt64(item.promoCountdown) < 0 {
                    timeCountdownLabel.text = ""
                    timeImgV.isHidden = true
                    timeCountdownLabel.isHidden = true
                    timeExpiredLabel.isHidden = false
                    timeExpiredLabel.text = kItemOfferHasExpired
                } else {
                    timeCountdownLabel.text = item.promoCountdownText
                    timeImgV.isHidden = false
                    timeCountdownLabel.isHidden = false
                    timeExpiredLabel.isHidden = true
                }
                promoBgImgV.isHidden = false
            } else {
                promoPercentValueLabel.text = ""
                
                promoView.isHidden = true
                promoBgImgV.isHidden = true
                timeImgV.isHidden = true
                timeCountdownLabel.isHidden = true
                timeExpiredLabel.isHidden = true
            }
        }
    }
    
    func setViewFrame(layout: SearchResultLayoutStyle = .grid) {
        if layout == SearchResultLayoutStyle.grid {
            
            imgV.frame = CGRect(x: (self.width - kImgViewWidth) / 2, y: 30, width: kImgViewWidth, height: kImgViewWidth)
            
            if validDouble(item?.listPrice) - validDouble(item?.price) > kOneInMillion {
                nameLabel.frame = CGRect(x: 15, y: imgV.frame.maxY + 5, width: self.frame.width - 40, height: 25)
                nameLabel.numberOfLines = 2
            } else {
                nameLabel.frame = CGRect(x: 15, y: imgV.frame.maxY + 5, width: self.frame.width - 40, height: 35)
                nameLabel.numberOfLines = 3
            }
            
            soldoutImgV.frame.size = CGSize(width: imgV.width / 2, height: imgV.width / 2)
            soldoutImgV.center = imgV.center
            
            promoBgImgV.frame = CGRect(x: imgV.frame.maxX - kItemViewOffViewWH + 10, y: imgV.y - 10, width: kItemViewOffViewWH, height: kItemViewOffViewWH)
        } else {
            
            imgV.frame = CGRect(x: 20, y: 20, width: self.frame.height - 40, height: self.frame.height - 40)
            
            if validBool(item?.isPromoItem) && validInt64(item?.promoCountdown) > 0 {
                nameLabel.frame = CGRect(x: imgV.width + 40, y: 10 * kProkScreenWidth * kProkScreenWidth + 5, width: self.frame.width - imgV.width - 60, height: 25)
                nameLabel.numberOfLines = 2
            } else {
                nameLabel.frame = CGRect(x: imgV.width + 40, y: 10 * kProkScreenWidth * kProkScreenWidth, width: self.frame.width - imgV.width - 60, height: 35)
                nameLabel.numberOfLines = 3
            }
            
            soldoutImgV.frame.size = CGSize(width: imgV.width / 2, height: imgV.width / 2)
            soldoutImgV.center = imgV.center
            
            promoBgImgV.frame = CGRect(x: imgV.frame.maxX - kItemViewOffViewWH + 10, y: imgV.y - 2, width: kItemViewOffViewWH, height: kItemViewOffViewWH)
        }
        
        promoView.frame = promoBgImgV.frame
        promoPercentValueLabel.frame =  CGRect(x: 0, y: promoView.width / 9, width: promoView.width, height: promoView.height / 2)
        promoTextLabel.frame = CGRect(x:0, y: promoView.height / 2 + 1 * kProkScreenWidth, width: promoView.width, height: 11)
        promoPercentValueLabel.font = UIFont.boldSystemFont(ofSize: promoView.width / 3.5)
        promoTextLabel.font = UIFont.systemFont(ofSize: promoView.width / 4.1)
    }
    
    func refreshCountdown() {
        if item.isPromoItem && validInt64(self.item.promoCountdown) > 0 {
            timeImgV.isHidden = false
            timeCountdownLabel.isHidden = false
            timeCountdownLabel.text = validString(item.promoCountdownText)
        } else {
            timeImgV.isHidden = true
            timeCountdownLabel.isHidden = true
        }
    }
}
