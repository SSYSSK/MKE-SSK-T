//
//  SSTCategoryViewCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/8/24.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTCategoryViewCell: UITableViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    
    var category: SSTCategory! {
        didSet {
            iconImage.setImage(fileUrl: validString(category.imgUrl), placeholder: KCategory_loading)
            nameL.text = clearName(category.name)
        }
    }
    
    var brand: SSTBrand! {
        didSet {
            iconImage.setImage(fileUrl: validString(brand.brandLogo), placeholder: KCategory_loading)
            nameL.text = clearName(brand.brandName)
        }
    }

}
