//
//  XTPhotoBrowserViewCell.swift
//  XTPhotoBrowser
//
//  Created by 李贵鹏 on 16/8/20.
//  Copyright © 2016年 李贵鹏. All rights reserved.
//

import UIKit


class XTPhotoBrowserViewCell: UICollectionViewCell {
    
    lazy var imageView : UIImageView = UIImageView()
    var image : UIImage = UIImage()
    var codCells = [SSTCODCell]()
    var nameLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var item : SSTApplyCodFile? {
        didSet {

            nameLabel.frame = CGRect(x: 0, y: 27*kProkScreenWidth, width: kScreenWidth, height: 20*kProkScreenWidth)
            nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
            nameLabel.textAlignment = NSTextAlignment.center
            nameLabel.textColor = UIColor.white
            nameLabel.text = item?.filetitle
            
            // 3.根据image计算出来放大之后的frame
            
            if imageFrame.height > kScreenHeight - 80 {
                imageFrame = CGRect(x: imageFrame.origin.x, y: 80, width: imageFrame.size.width, height: kScreenHeight - 80)
            } else {
                self.imageView.frame = CGRect(x: (kScreenWidth - imageFrame.width)/2, y: (kScreenHeight - imageFrame.height )/2, width: imageFrame.width, height: imageFrame.height)    
            }

            if let tItem = item {
                if tItem.image == nil {
                    self.imageView.setImage(fileUrl: tItem.filepath, placeholder: "icon_loading")
                } else {
                    self.imageView.image = tItem.image
                }
                if let image = self.imageView.image {
                    self.imageView.frame = calculateFrameWithImage(image: image)
                }
            }
        }
    }
}
