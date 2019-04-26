//
//  SSTPageView.swift
//  sst-ios
//
//  Created by Zal Zhang on 7/15/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTPageView: SSTScrollView, UIScrollViewDelegate {
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func setParas(_ items: [AnyObject], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String, inBundle: Bool = false) {
        super.setParas(items, itemWidth: itemWidth, itemHeight: itemHeight, placeholder: placeholder, inBundle: inBundle)
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
    }
    
    func setScrollViewContentOffset() {
        pageControl.currentPage = Int((scrollView.contentOffset.x + CGFloat( itemWidth / 2)) / itemWidth)
    }
    
    // MARK: -- UIScrollViewDelegate
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setScrollViewContentOffset()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        setScrollViewContentOffset()
    }
    
}
