//
//  SSTGuideView.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/7/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTGuideView: SSTPageView {
    
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var skipButtonTopConstraint: NSLayoutConstraint!
    
    var viewDisappeard: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        skipButtonTopConstraint.constant = kScreenNavigationHeight - 24
        
        if biz.guideData.guides.count == 0 {
            viewDisappeard?()
        } else {
            setParas(biz.guideData.guides, itemWidth: kScreenWidth, itemHeight: kScreenHeight, placeholder: kGuidePlaceholderImgName, inBundle: biz.guideData.inBundle)
            refreshUI()
        }
    }
    
    override func getItemView(_ ind: Int) -> UIView {
        let pageView = loadNib("\(SSTGuidePageView.classForCoder())") as! SSTGuidePageView
        pageView.frame = CGRect(x: CGFloat(ind) * itemWidth, y: 0, width: itemWidth, height: itemHeight)
        pageView.guide = items.validObjectAtIndex(ind) as? SSTGuide
        return pageView
    }
    
    func setSkipButton() {
        if biz.guideData.skipAll == 0 || pageControl.currentPage == biz.guideData.guides.count - 1 {
            skipButton.isHidden = true
        } else {
            skipButton.isHidden = false
        }
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        viewDisappeard?()
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if pageControl.currentPage == biz.guideData.guides.count - 1 {
            //
        } else {
            startButton.isHidden = true
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        refreshUI()
    }
    
    fileprivate func refreshUI() {
        if pageControl.currentPage == biz.guideData.guides.count - 1 {
            if startButton.isHidden == true {
                startButtonAnimation()
            }
        } else {
            startButton.isHidden = true
        }
        setSkipButton()
    }
    
    fileprivate func startButtonAnimation() {
        startButton.isHidden = false
        startButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 1, delay: 0.1, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.startButton.transform = CGAffineTransform.identity
        }) { (_) -> Void in
            
        }
    }
}
