//
//  SSTCategoryTwoView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/8/24.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTCategoryTwoView: UITableViewCell {

    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var nameL: UILabel!
    
    var category: SSTCategory? {
        didSet {
            if let cate = category {
                imgV.setImage(fileUrl: validString(cate.imgUrl), placeholder: kCategoryTwoIconName, callback: { (data, error) in
                    if error == nil {
                        let scaleRate = validCGFloat(self.imgV.image?.size.width) / 25
                        self.imgV.image = self.imgV.image?.scale(rate: 1 / scaleRate)
                    }
                })
                nameL.text = clearName(cate.name)
            }
        }
    }
    
    var devices: SSTDevices? {
        didSet {
            if let cate = devices {
                imgV.setImage(fileUrl: validString(cate.imgUrl), placeholder: kCategoryTwoIconName)
                nameL.text = clearName(cate.deviceName)
            }
        }
    }
    
    var series: SSTSeries? {
        didSet {
            if let cate = series {
                imgV.setImage(fileUrl: validString(cate.imgUrl), placeholder: kCategoryTwoIconName)
                nameL.text = clearName(cate.seriesName)
            }
        }
    }
}

