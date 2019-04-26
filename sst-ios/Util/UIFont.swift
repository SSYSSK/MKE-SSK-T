//
//  UIFont.swift
//  sst-ios
//
//  Created by Amy on 2017/1/17.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

extension UIFont {
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return (string as NSString).boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude),
                                                         options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                                         attributes: [NSAttributedStringKey.font: self],
                                                         context: nil).size
    }
}
