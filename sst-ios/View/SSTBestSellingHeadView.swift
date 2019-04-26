//
//  SSTBestSellingHeadView.swift
//  sst-ios
//
//  Created by Amy on 16/8/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTBestSellingHeadView: UICollectionReusableView {

    @IBOutlet weak var indexViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var indexViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var indexView: UIView!
    @IBOutlet weak var mostPopularBtn: UIButton!
    @IBOutlet weak var bestSellingBtn: UIButton!
    
    var selectTypeInCartBlock:((_ type: String) -> Void)?

    @IBAction func clickedBestSellingEvent(_ sender: AnyObject) {
        bestSellingBtn.setTitleColor(kPurpleColor, for: UIControlState())
        mostPopularBtn.setTitleColor(UIColor.black, for: UIControlState())
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.indexViewLeftConstraint.constant = 20
            self.indexViewWidthConstraint.constant = kScreenWidth / 2 - 40
            self.indexView.frame.origin.x = 0

        })
        if let block = selectTypeInCartBlock {
            block(kCartBestSelling)
        }
    }
    
    @IBAction func clickedMostPopularEvent(_ sender: AnyObject) {
        mostPopularBtn.setTitleColor(kPurpleColor, for: UIControlState())
        bestSellingBtn.setTitleColor(UIColor.black, for: UIControlState())
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.indexViewLeftConstraint.constant = kScreenWidth / 2 + 20
            self.indexViewWidthConstraint.constant = kScreenWidth / 2 - 40
            self.indexView.frame.origin.x = kScreenWidth / 2 + 20

        })
        if let block = selectTypeInCartBlock {
            block(kCartMostPopular)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bestSellingBtn.setTitleColor(kPurpleColor, for: UIControlState())
        self.indexViewWidthConstraint.constant = kScreenWidth / 2 - 40
    }
    
}
