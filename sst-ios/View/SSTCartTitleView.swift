//
//  SSTCartTitleView.swift
//  sst-ios
//
//  Created by Zal Zhang on 5/2/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTCartTitleView: UIView {
    
    var shopMoreClick: (() -> Void)?

    @IBOutlet weak var cartTitleBg: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var shopMoreButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.frame = CGRect(x: 10, y: 36, width: kScreenWidth - 100, height: 13)
        shopMoreButton.frame.origin = CGPoint(x: kScreenWidth - shopMoreButton.frame.width - 10, y: shopMoreButton.frame.origin.y)
    }
    
    @IBAction func clickedShopMore(_ sender: Any) {
        shopMoreClick?()
    }

}
