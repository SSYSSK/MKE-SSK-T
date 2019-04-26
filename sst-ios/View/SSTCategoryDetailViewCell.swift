//
//  SSTCategoryDetailViewCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/21/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTCategoryDetailViewCell: SSTBaseCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var arrowImgV: UIImageView!
    @IBOutlet weak var nameLeadingConstraint: NSLayoutConstraint!
    
    var levelObject: SSTLevelObject! {
        didSet {
            let category = levelObject.obj as? SSTCategory
            nameLabel.font = UIFont.systemFont(ofSize: 13 * ( 1 - CGFloat(levelObject!.level - 1) / 10) )
            nameLabel.textColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: ( 1 - CGFloat(levelObject!.level - 1) / 20))
            nameLabel.text = category?.name
            nameLeadingConstraint.constant = CGFloat(15 * levelObject.level)
            if validInt(levelObject.subs?.count) == 0 {
                arrowImgV.image = UIImage(named: kIconGoInImageName)
            } else {
                if levelObject.isExpanded == true {
                    arrowImgV.image = UIImage(named: kIconCollapseImageName)
                } else {
                    arrowImgV.image = UIImage(named: kIconExpandImageName)
                }
            }
        }
    }
}
