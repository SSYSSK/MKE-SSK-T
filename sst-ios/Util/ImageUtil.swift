//
//  ImageUtil.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/26/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

extension UIImage {
    
    /**
     *  reset image size
     */
    func reSizeImage(reSize:CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height))
        if let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return reSizeImage
        }
        return UIImage()
    }
    
    /**
     *  scale by rate
     */
    func scale(rate: CGFloat) -> UIImage {
        let reSize = CGSize(width: self.size.width * rate, height: self.size.height * rate)
        return reSizeImage(reSize: reSize)
    }

}
