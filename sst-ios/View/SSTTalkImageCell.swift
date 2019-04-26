//
//  SSTTalkImageCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/21/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTTalkImageCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var imageViewWidthContant: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeightContant: NSLayoutConstraint!
    
    var imageClick: ( (_ imgUrl: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(SSTTalkImageCell.imageTap(_:)))
        imgView.isUserInteractionEnabled = true
        imgView.addGestureRecognizer(tap)
    }
    
    var record: SSTContactRecord? {
        didSet {
            imgView.setImage(fileUrl: validString(record?.imgUrl), placeholder: kIcon_loading)
        }
    }
    
    var reply: SSTContactReply? {
        didSet {
            imgView.setImage(fileUrl: validString(reply?.thumbnail), placeholder: kIcon_loading) { data, error in
                if error == nil {
                    let imgWScaled: CGFloat = max(min(validCGFloat(self.imgView.image?.size.width), kScreenWidth - 150), 25) / validCGFloat(self.imgView.image?.size.width)
                    let imgHScaled: CGFloat = max(min(validCGFloat(self.imgView.image?.size.height), 159), 25) / validCGFloat(self.imgView.image?.size.height)
                    let imgScale = min(imgWScaled, imgHScaled)
                    self.imageViewWidthContant.constant = validCGFloat(self.imgView.image?.size.width) * imgScale
                    self.imageViewHeightContant.constant = validCGFloat(self.imgView.image?.size.height) * imgScale
                    var cellFrame = self.frame
                    cellFrame.size.height = self.imageViewHeightContant.constant + 22 * 2
                    self.frame = cellFrame
                }
            }
        }
    }
    
    @objc func imageTap(_ tap: UITapGestureRecognizer) {
        imageClick?(validString(reply?.imgUrl))
    }

}
