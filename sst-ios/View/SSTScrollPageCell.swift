//
//  SSTScrollPageCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/12/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kScrollPageCellImageViewContentMode = UIViewContentMode.scaleAspectFit

class SSTScrollPageCell: SSTScrollCell {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    fileprivate var timer: Timer?
    fileprivate var interval = 3.0
    
    var hotObjs: [SSTHotProduct]!
    
    func getScrollPageCellImageViewRect(ind: Int) -> CGRect {
        return CGRect(x: CGFloat(ind + 1) * pageWidth + pageWidth * 0.3, y: (pageWidth * 0.55 - pageWidth * 0.4) / 2, width: pageWidth * 0.4, height: pageWidth * 0.4)
    }
    
    override func setParas(_ objs: [Any], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String) {
        
        self.pageCount = objs.count
        self.pageWidth = itemWidth
        self.pageHeight = itemHeight
        self.placeholderImgName = placeholder
        self.objs = objs
        
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        
        scrollView.isScrollEnabled = false
        if objs.count > 0 {
            initUI()
            if objs.count > 1 {
                startTimer()
                scrollView.isScrollEnabled = true
            }
        } else {
            let imageView = UIImageView(frame: getScrollPageCellImageViewRect(ind: -1))
            imageView.contentMode = kScrollPageCellImageViewContentMode
            imageView.image = UIImage(named: self.placeholderImgName)
            self.scrollView.addSubview(imageView)
        }
        
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
    }
    
    func setParas(_ objs:[SSTHotProduct], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String) {
        
        self.pageCount = objs.count
        self.pageWidth = itemWidth
        self.pageHeight = itemHeight
        self.placeholderImgName = placeholder
        self.hotObjs = objs
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
        scrollView.isScrollEnabled = false
        if objs.count > 0 {
            initHotUI()
            if objs.count > 1 {
                startTimer()
                scrollView.isScrollEnabled = true
            }
        } else {
            let imgV = UIImageView(frame: self.frame)
            imgV.image = UIImage(named: self.placeholderImgName)
            imgV.frame = CGRect(x: 0, y: 0, width: pageWidth * 0.6, height: pageHeight * 0.5)
            self.scrollView.addSubview(imgV)
        }
        
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
    }

    func initHotUI() {
        scrollView.contentSize = CGSize(width: CGFloat(pageCount) * pageWidth, height: 0)
        for index in 0 ..< pageCount {
            let imageView = UIImageView(frame: CGRect(x: CGFloat(index) * pageWidth, y: 0, width: pageWidth, height: pageHeight))
            let dataInd = (index + pageCount) % pageCount
            
            if let imagesPath = hotObjs[dataInd].imagesPath{
                imageView.setImage(fileUrl: imagesPath, placeholder: kIcon_loading)
            } else {
                imageView.image = UIImage(named: kIcon_loading)
            }
            
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedProduct))
            tap.numberOfTapsRequired = 1
            imageView.addGestureRecognizer(tap)
            
            if let product = hotObjs[dataInd].productId{
                imageView.tag = validInt(product)
            }
            scrollView.addSubview(imageView)
        }
        
        pageControl.numberOfPages = pageCount
        pageControl.currentPage = 0
    }
    
    override func initUI() {
        for subV in scrollView.subviews {
            subV.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(pageCount + 2) * pageWidth, height: 0)
        
        for index in -1 ... pageCount {
            let imageView = UIImageView(frame: getScrollPageCellImageViewRect(ind: index))
            let dataInd = (index + pageCount) % pageCount
            let dataObj = objs.validObjectAtIndex(dataInd) as? URLStringConvertible
            imageView.contentMode = kScrollPageCellImageViewContentMode
            imageView.setImage(fileUrl: validString(dataObj?.URLString), placeholder: placeholderImgName)
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedView))
            imageView.addGestureRecognizer(tap)
            
            scrollView.addSubview(imageView)
        }
        scrollView.setContentOffset(CGPoint(x: pageWidth,y: 0), animated: false)
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setScrollViewContentOffset()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setScrollViewContentOffset()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }

}
