//
//  SSTImageTitle.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/22.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTImageTitle: UIView {

    var imageTitleClick: ((_ title:String, _ willUpload: Bool) -> Void)?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    var imageType:CODImageType = .otherImage
    
    @IBAction func cancelEvent(_ sender: AnyObject) {
        imageTitleClick?("", false)
    }
    
    @IBAction func enterEvent(_ sender: AnyObject) {
        if (textField.text == kID) && imageType != .idImage {
            SSTToastView.showError(kCODInputOtherTitle)
        } else if (textField.text == kBusinessLicense) && imageType != .businessImage {
            SSTToastView.showError(kCODInputOtherTitle)
        } else {
            imageTitleClick?(validString(textField.text), true)
        }
    }
}
