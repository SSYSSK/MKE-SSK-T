//
//  SSTHomeHeadView.swift
//  sst-ios
//
//  Created by Amy on 16/4/29.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTSlideView: SSTPageView {
    
    fileprivate var timer: Timer?
    fileprivate var interval = 3.0
    
    override func setParas(_ items: [AnyObject], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String, inBundle: Bool = false) {
        super.setParas(items, itemWidth: itemWidth, itemHeight: itemHeight, placeholder: placeholder, inBundle: inBundle)
        if items.count > 1 {
            startTimer()
        }
    }
    
    override func initUI() {
        for subV in scrollView.subviews {
            subV.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(items.count + 2) * itemWidth, height: 0)
        
        for ind in -1 ... items.count {
            let imageView = UIImageView(frame: CGRect(x: itemWidth * CGFloat(ind + 1), y: 0, width: itemWidth, height: itemHeight))
            
            let dataInd = (ind + items.count) % items.count
            let dataObj = items.validObjectAtIndex(dataInd) as? URLStringConvertible
            
            imageView.contentMode = .scaleToFill
            imageView.setImage(fileUrl: validString(dataObj?.URLString), placeholder: placeholderImgName)
            imageView.tag = dataInd
            
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedView))
            imageView.addGestureRecognizer(tap)
            
            scrollView.addSubview(imageView)
        }
        
        scrollView.setContentOffset(CGPoint(x: itemWidth, y: 0), animated: false)
    }
    
    override func setScrollViewContentOffset() {
        let page = Int((scrollView.contentOffset.x + CGFloat( itemWidth / 2)) / itemWidth) - 1
        if page == -1 {
            scrollView.setContentOffset(CGPoint(x: CGFloat(items.count - 1) * itemWidth, y: 0), animated: false)
        } else if page == items.count {
            scrollView.setContentOffset(CGPoint(x: itemWidth, y: 0), animated: false)
        }
        pageControl.currentPage = (page + items.count) % items.count
    }
    
    // MARK: Timer
    
    fileprivate func startTimer() {
        if timer == nil {
            timer = Timer(timeInterval: 3.0, target: self, selector:#selector(showNext), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func showNext() {
        scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x + itemWidth, y: 0), animated: true)
    }
    
    // MARK: -- UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        stopTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startTimer()
    }
}
