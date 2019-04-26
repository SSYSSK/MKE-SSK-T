//
//  SSTPromoMsgView.swift
//  sst-ios
//
//  Created by Zal Zhang on 11/29/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTPromoMsgView: UIView, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!

    var objs: [String] = [String]()

    fileprivate var pageWidth = kScreenWidth
    fileprivate var pageHeight: CGFloat = 35
    fileprivate var currentPage = 0
    
    fileprivate var timer: Timer?
    fileprivate var interval = 3.0
    
    fileprivate var title1Width: CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc func timerAlarm() {
        if let titleLabel = scrollView.viewWithTag(9999) as? UILabel {
            titleLabel.frame.origin = CGPoint(x: titleLabel.x - 1, y: titleLabel.y)
            if titleLabel.x <= 10 - title1Width {
                titleLabel.frame.origin = CGPoint(x: 10, y: titleLabel.y)
            }
        }
    }
    
    func initUI() {
        scrollView.contentSize = CGSize(width: pageWidth, height: CGFloat(objs.count + 2) * pageHeight)
        for view in scrollView.subviews {
            view.removeFromSuperview()
        }
        for ind in 0 ... objs.count {
            let dataInd = (ind + objs.count) % objs.count
            let label = UILabel(frame: CGRect(x: 15, y: CGFloat(ind) * pageHeight, width: 5000, height: pageHeight))
            label.attributedText = SSTDealMessage.toAttributedString(validString(objs.validObjectAtIndex(dataInd))).addFontSize(size: 13)
            label.tag = 1001 + ind
            scrollView.addSubview(label)
        }
        scrollView.delegate = self
        scrollView.isScrollEnabled = false
        self.addSubview(scrollView)
        TaskUtil.delayExecuting(0.01) {
            self.setScrollViewContentOffset()
        }
    }
    
    func setDealMessage() {
        objs = biz.dealMessage.msgs
        if objs.count > 0 {
            initUI()
            startTimer()
        }
    }
    
    func findInOldArray(str: String) -> Bool {
        for oldStr in objs {
            if str == oldStr {
                return true
            }
        }
        return false
    }

    func setArray(array: Array<Any>) {
        var isSameWithOldArray = true
        if array.count == objs.count {
            for newStr in array {
                if findInOldArray(str: validString(newStr)) == false {
                    isSameWithOldArray = false
                    break
                }
            }
            if isSameWithOldArray {
                return
            }
        }
        
        var strs = [String]()
        for str in array {
            strs.append(validString(str))
        }
        objs = strs
        
        if objs.count == 1 { // just only one lable, so need to show it horizently repeatedly when it's width is greater than sreen width
            let title = validString(objs.first).escapeHtmlP()
            if SSTDealMessage.toAttributedString(title).sizeByFont(font: UIFont.boldSystemFont(ofSize: 12)).width > kScreenWidth - 30 {
                for subV in self.scrollView.subviews {
                    subV.removeFromSuperview()
                }
                
                let titleLabel = UILabel(frame: CGRect(x:10, y:0, width:5000, height:pageHeight))
                titleLabel.tag = 9999
                titleLabel.textAlignment = .left
                
                let title1 = "\(title)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
                let title2 = "\(title1)\(title)"
                self.title1Width = SSTDealMessage.toAttributedString(title1).sizeByFont(font: UIFont.boldSystemFont(ofSize: 12)).width
                titleLabel.attributedText = SSTDealMessage.toAttributedString(title2)
                
                self.scrollView.addSubview(titleLabel)
                self.scrollView.clipsToBounds = true
                
                TaskUtil.delayExecuting(3, block: {
                    NotificationCenter.default.addObserver(self, selector:#selector(self.timerAlarm), name: kEveryOneInTwentySecondNotification, object: nil)
                })
            } else {
                initUI()
            }
        } else if objs.count > 1 {
            initUI()
            startTimer()
        }
    }
    
    func setScrollViewContentOffset() {
        if currentPage >= objs.count {
            currentPage = 0
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        
        let width = validString(objs.validObjectAtIndex(currentPage)).escapeHtml().sizeByWidth(font: 13, width: 5000).width
        if width > kScreenWidth - 30 {
            if let txtLabel = self.scrollView.viewWithTag(1001 + currentPage) as? UILabel {
                UIView.animate(withDuration: 1.9, delay: 1.1, animations: {
                    txtLabel.frame.origin = CGPoint(x: 15 - (width - kScreenWidth + 40), y: txtLabel.frame.origin.y)
                }, completion: { (Bool) in
                    TaskUtil.delayExecuting(0.5, block: {
                        txtLabel.frame.origin = CGPoint(x: 15, y: txtLabel.frame.origin.y)
                    })
                })
            }
        }
    }
    
    // MARK: Timer
    
    fileprivate func startTimer() {
        if objs.count > 1 && timer == nil {
            timer = Timer(timeInterval: 3.0, target: self, selector:#selector(showNext), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func showNext() {
        currentPage = currentPage + 1
        scrollView.setContentOffset(CGPoint(x: 0, y: CGFloat(currentPage) * pageHeight), animated: true)
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
