//
//  SSTDiscountsView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/25.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTDiscountsView: UIView {
    var labelH:CGFloat=20
    
    var ccpScrollView = UIScrollView()
    
    var titleArray: [String]! {
        didSet{
            if titleArray.count < 2 {
                self.removeTimer()
            }
            labelH = 20
            self.ccpScrollView.frame =  CGRect(x: 0, y: 0, width: kScreenWidth-50-40, height: labelH)
            ccpScrollView.showsHorizontalScrollIndicator = false;
            ccpScrollView.showsVerticalScrollIndicator = false;
            ccpScrollView.isScrollEnabled = false;
            ccpScrollView.isPagingEnabled = true;
            
            ccpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            self.addSubview(self.ccpScrollView)
            
            self.ccpScrollView.delegate = self
            
            let contentH = self.labelH * CGFloat(titleArray.count);
            self.ccpScrollView.contentSize = CGSize(width: 0, height: contentH)
            
            for  label in self.ccpScrollView.subviews {
                label.removeFromSuperview()
            }
            
            for ind in 0 ..< titleArray.count {
                let titleLabel = UILabel();
                let labelY = ind * Int(labelH);
                titleLabel.frame = CGRect(x: 0, y: CGFloat(labelY), width:  kScreenWidth-50, height: labelH)
                titleLabel.text = validString(titleArray.validObjectAtIndex(ind))
                titleLabel.font = UIFont.systemFont(ofSize: 13)
                self.ccpScrollView.addSubview(titleLabel)
            }
            
            if titleArray.count > 1 {
                self.addTimer()
            }
        }
    }
    
    var titleAtiArray: [NSMutableAttributedString]! {
        didSet{
            if titleAtiArray.count < 2 {
                self.removeTimer()
            }
            labelH = 20
            self.ccpScrollView.frame =  CGRect(x: 0, y: 0, width: kScreenWidth-50-40, height: labelH)
            ccpScrollView.showsHorizontalScrollIndicator = false;
            ccpScrollView.showsVerticalScrollIndicator = false;
            ccpScrollView.isScrollEnabled = false;
            ccpScrollView.isPagingEnabled = true;
            
            ccpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            
            self.addSubview(self.ccpScrollView)
            
            self.ccpScrollView.delegate = self
            
            let contentH = self.labelH * CGFloat(titleAtiArray.count);
            self.ccpScrollView.contentSize = CGSize(width: 0, height: contentH)
            
            for  label in self.ccpScrollView.subviews {
                label.removeFromSuperview()
            }
            
            for ind in 0 ..< titleAtiArray.count {
                let titleLabel = UILabel();
                let labelY = ind * Int(labelH);
                titleLabel.frame = CGRect(x: 0, y: CGFloat(labelY), width:  kScreenWidth-50, height: labelH)
                titleLabel.attributedText = titleAtiArray.validObjectAtIndex(ind) as? NSAttributedString
                titleLabel.font = UIFont.systemFont(ofSize: 13)

                self.ccpScrollView.addSubview(titleLabel)
            }
            
            if titleAtiArray.count > 1 {
                self.addTimer()
            }
        }
    }

    
    var timer :Timer?
    
    func removeTimer() {
        if let t = self.timer{
            t.invalidate();
            self.timer = nil;
        }
    }
    
    func addTimer() {
        if let t = self.timer {
            t.invalidate()
            self.timer = nil
        }
        self.timer = Timer(timeInterval: 3.0, target: self, selector: #selector(SSTDiscountsView.nextLabel), userInfo: nil, repeats: true)
        RunLoop.main.add(self.timer!, forMode: RunLoopMode.commonModes)
    }
    
    @objc func nextLabel() {
        var oldPoint = self.ccpScrollView.contentOffset
        oldPoint.y += self.ccpScrollView.frame.size.height
        self.ccpScrollView.setContentOffset(oldPoint, animated: true)
    }
}

extension SSTDiscountsView:UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.titleArray != nil {
            if self.ccpScrollView.contentOffset.y >= self.ccpScrollView.frame.size.height * CGFloat(self.titleArray.count) {
                self.ccpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
        
        if self.titleAtiArray != nil {
            if self.ccpScrollView.contentOffset.y >= self.ccpScrollView.frame.size.height * CGFloat(self.titleAtiArray.count) {
                self.ccpScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.removeTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.addTimer()
    }
}
