//
//  SSTGuidePageView.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/8/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTGuidePageView: UIView {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    var guide: SSTGuide! {
        didSet {
            if biz.guideData.inBundle {
                imgView.image = UIImage(named: guide.imgUrl)
            } else {
                if let imgData = FileOP.read(fileName: "guide_\(validString(guide.id))", inBundle: false) as? Data {
                    imgView.image = UIImage(data: imgData)
                }
            }
            titleLabel.text = validString(guide.title)
            titleLabel.font = UIFont.boldSystemFont(ofSize: 19 * kProkScreenWidth)
            infoLabel.attributedText = validString(guide.content).toAttributedString().addColor(color: UIColor.white).addFontSize(size: 15 * kProkScreenWidth).addLineSpaceTextAligment(space: 13 * kProkScreenWidth, textAlignment: .center)
        }
    }
}
