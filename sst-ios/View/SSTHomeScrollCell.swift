//
//  SSTHomeScrollCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/19.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

//let kStartBtnWidth: CGFloat = 140.0
//let kStartBtnHeight:CGFloat = 40.0

class SSTHomeScrollCell: SSTBaseCell, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var pageCount: Int!
    var pageWidth = kScreenWidth
    var pageHeight = kScreenWidth / 2
    var placeholderImgName = kHomeSlidePlaceholderImgName
    
    var objs: [AnyObject]!
    
    
    func setParas(_ objs: [AnyObject], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String) {
        self.pageCount = objs.count
        self.pageWidth = itemWidth
        self.pageHeight = itemHeight
        self.placeholderImgName = placeholder
        self.objs = objs
        
        if objs.count > 0 {
            initUI()
        } else {
            pageControl.numberOfPages = 0
        }
    }
    
    func initUI() {
        scrollView.contentSize = CGSize(width: CGFloat(pageCount) * pageWidth, height: 0)
        for index in 0 ..< pageCount {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * pageWidth, y: 0, width: pageWidth, height: pageHeight))
            let dataInd = (index + pageCount) % pageCount
            imageView.image = UIImage(named: validString(objs[dataInd]))
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedView))
            imageView.addGestureRecognizer(tap)
            scrollView.addSubview(imageView)
        }
        
    }
    
    func showNextPage(_ page: Int) {
        scrollView.setContentOffset(CGPoint(x: CGFloat(page) * pageWidth, y: 0), animated: true)
    }
    
    // MARK: Scrollview Delegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x + CGFloat( pageWidth / 2)) / pageWidth)
        showNextPage(page)
    }
}
