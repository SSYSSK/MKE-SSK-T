//
//  CategoryBrandHeadView.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/27.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTCategoryBrandHeadView: SSTHomeScrollCell {
    
    fileprivate var timer: Timer?
    fileprivate var interval = 3.0
    fileprivate var imageType: ImageType?
    
    override func setParas(_ objs: [AnyObject], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String) {
        
        self.pageCount = objs.count
        self.pageWidth = itemWidth
        self.pageHeight = itemHeight
        self.placeholderImgName = placeholder
        self.objs = objs
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        if objs.count > 0 {
            initUI()
            startTimer(objs)
        } else {
            pageControl.numberOfPages = 0
        }
    }
    
    func startTimer(_ objs: [AnyObject]) {
        if objs.count > 1 {
            startTimer()
        }
    }
    
    override func initUI() {
        if pageCount == 1 {
            scrollView.contentSize = CGSize(width: pageWidth, height: 0)
        } else {
            scrollView.contentSize = CGSize(width: CGFloat(pageCount + 2) * pageWidth, height: 0)
        }
        
        for index in -1 ... pageCount {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index + 1) * pageWidth, y: 0, width: pageWidth, height: pageHeight))
            let dataInd = (index + pageCount) % pageCount
            let dataObj = objs?.validObjectAtIndex(dataInd) as? SSTHotProduct
            imageView.tag = dataInd
            imageView.setImage(fileUrl: validString(dataObj?.imagesPath), placeholder: kIcon_slide)
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedView))
            imageView.addGestureRecognizer(tap)
            
            scrollView.addSubview(imageView)
        }
        scrollView.setContentOffset(CGPoint(x: pageWidth,y: 0), animated: false)
        scrollView.isPagingEnabled = true
        pageControl.currentPageIndicatorTintColor = kPurpleColor
        pageControl.pageIndicatorTintColor = UIColor.white;
        
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
    }
    
    func setScrollViewContentOffset() {
        if pageControl.currentPage == 0 {
            scrollView.setContentOffset(CGPoint(x: pageWidth,y: 0), animated: false)
        } else if pageControl.currentPage == pageCount - 1 {
            scrollView.setContentOffset(CGPoint(x: CGFloat(pageCount) * pageWidth,y: 0), animated: false)
        }
    }
    
    // MARK: Timer
    
    fileprivate func startTimer() {
        timer = Timer(timeInterval: 3.0, target: self, selector:#selector(showNext), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func showNext() {
        let pgInd = pageControl.currentPage + 2
        scrollView.setContentOffset(CGPoint(x: CGFloat(pgInd) * pageWidth, y: 0), animated: true)
    }
    
    // MARK: Scrollview Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int((scrollView.contentOffset.x + CGFloat( pageWidth / 2)) / pageWidth) - 1
        pageControl.currentPage = (page + pageCount) % pageCount
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setScrollViewContentOffset()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setScrollViewContentOffset()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer(objs)
    }
    
    override func clickedView(_ imageView: UITapGestureRecognizer) {
        if let item = self.objs.validObjectAtIndex(validInt(imageView.view?.tag)) {
            itemClick?(item)
        }
    }
}
