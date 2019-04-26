//
//  SSTRefreshHeaderView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/14/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import PullToRefreshKit

let kRefreshImageName = "star1"

func setRefreshFooter(_ footer: DefaultRefreshFooter) {
    footer.setText("Pull up to refresh", mode: RefreshKitFooterText.pullToRefresh)
    footer.setText("", mode: RefreshKitFooterText.noMoreData)
    footer.setText("Refreshing...", mode: RefreshKitFooterText.refreshing)
    footer.setText("Tap to load more", mode: RefreshKitFooterText.tapToRefresh)
    footer.setText("", mode: RefreshKitFooterText.scrollAndTapToRefresh)
    footer.textLabel.textColor  = UIColor.darkGray
    footer.refreshMode = .scrollAndTap
    footer.backgroundColor = UIColor.groupTableViewBackground
}

class SSTRefreshHeaderView: UIView, RefreshableHeader {
    
    let imageView = UIImageView()
    
    var result: RefreshResult?  // because no result changed when calling didCompleteEndRefershingAnimation, so add it to help to keep result for this function
    var finishView: UIView?     // add custom view when finishing loading data.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 46.8 * kProkScreenWidth * 1.3, height: 30.8 * kProkScreenWidth * 1.3)
        imageView.center = CGPoint(x: self.bounds.width/2.0, y: self.bounds.height/2.0)
        addSubview(imageView)
        
        self.backgroundColor = UIColor.black
    }
    
    func showFinishView(msg: String, imgName: String) {
        
        if finishView == nil {
            let finishImageView = UIImageView()
            let finishLabel = UILabel()
            
            finishImageView.frame = CGRect(x:5, y: 5, width: 20, height: 20)
            finishImageView.image = UIImage(named: imgName)
            
            finishLabel.frame = CGRect(x: 30, y: 0, width: 150, height: 30)
            finishLabel.text = msg
            finishLabel.textColor = UIColor.gray
            finishLabel.font = UIFont.systemFont(ofSize: 15)
            finishLabel.textAlignment = NSTextAlignment.center
            
            finishView = UIView()
            finishView?.frame = CGRect(x: (self.width - 180)/2, y: 18, width: 180, height: 30)
            
            finishView?.addSubview(finishImageView)
            finishView?.addSubview(finishLabel)
        } else {
            for subV in validArray(finishView?.subviews) {
                if subV.isKind(of: UILabel.classForCoder()) {
                    (subV as! UILabel).text = msg
                } else if subV.isKind(of: UIImageView.classForCoder()) {
                    (subV as! UIImageView).image = UIImage(named: imgName)
                }
            }
        }
        
        finishView?.center = imageView.center
        if let tmpV = finishView {
            addSubview(tmpV)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - RefreshableHeader -
    func heightForRefreshingState() -> CGFloat {
        return 70
    }
    
    //监听百分比变化
    func percentUpdateDuringScrolling(_ percent:CGFloat) {
        self.superview?.backgroundColor = UIColor.black
        
        imageView.isHidden = (percent == 0)
        let adjustPercent = max(min(1.0, percent),0.0)
        let scale = 0.2 + (1.0 - 0.2) * adjustPercent;
        imageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        let imageName = kRefreshImageName
        let image = UIImage(named: imageName)
        imageView.image = image
    }
    
    //松手即将刷新的状态
    func didBeginRefreshingState() {
        let images = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14","15","16","17","18","19","20","21","22","23","24","25","26","27","28","29","30","31","32"].map { (name) -> UIImage in
            if let tmpImg = UIImage(named:"star\(name)") {
                return tmpImg
            } else {
                return UIImage()
            }
        }
        imageView.animationImages = images
        imageView.animationDuration = Double(images.count) * 0.03
        imageView.startAnimating()
    }
    
    //刷新结束，将要隐藏header
    func didBeginEndRefershingAnimation(_ result: RefreshResult) {
        
        self.result = result

        imageView.animationImages = nil
        imageView.stopAnimating()
        imageView.isHidden = true
        
        if let scrollView = self.superview?.superview as? UIScrollView {
            if scrollView.contentOffset.y < -64 {
                if self.result == .success {
                    showFinishView(msg: "Refresh Successful", imgName: "refreshFinish")
                } else {
                    showFinishView(msg: "Refresh Failed", imgName: "icon_delete")
                }
            }
        }
    }
    
    //刷新结束，完全隐藏header
    func didCompleteEndRefershingAnimation(_ result: RefreshResult) {
        self.finishView?.removeFromSuperview()
    }
}
