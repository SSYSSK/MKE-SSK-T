//
//  SSTScrollCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/12/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kStartBtnWidth: CGFloat = 140.0
let kStartBtnHeight:CGFloat = 40.0

class SSTScrollCell: SSTBaseCell, UIScrollViewDelegate {
    
    var scrollCellClick: ((_ productId: String) -> Void)?
   
    @IBOutlet weak var scrollView: UIScrollView!
    
    var pageCount: Int!
    var pageWidth = kScreenWidth - 200
    var pageHeight = kScreenWidth / 2
    var placeholderImgName = kHomeSlidePlaceholderImgName

    var objs:  [Any]!
   
    func setParas(_ objs: [Any], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String) {
        
        self.pageCount = objs.count
        self.pageWidth = itemWidth
        self.pageHeight = itemHeight
        self.placeholderImgName = placeholder
        self.objs = objs
        
        if  objs.count > 0 {
            initUI()
        } else {
            let imgV = UIImageView(frame: self.frame)
            imgV.image = UIImage(named: placeholderImgName)
            imgV.frame.size = CGSize(width: itemWidth, height: itemHeight)
            self.scrollView.addSubview(imgV)
            scrollView.isScrollEnabled = false
        }
    }
    
    @objc func clickedProduct(_ imageView:UITapGestureRecognizer){
        self.scrollCellClick?(validString(imageView.view?.tag))
    }

    func initUI() {
      
        scrollView.contentSize = CGSize(width: CGFloat(pageCount) * pageWidth, height: 0)
        for index in 0 ..< pageCount {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * pageWidth, y: 0, width: pageWidth, height: pageHeight))
            let dataInd = (index + pageCount) % pageCount

            imageView.setImage(fileUrl: validString(objs.validObjectAtIndex(dataInd)), placeholder: placeholderImgName)
            
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedView))
            imageView.addGestureRecognizer(tap)
            
            scrollView.addSubview(imageView)
            
            
        }
    }
}
