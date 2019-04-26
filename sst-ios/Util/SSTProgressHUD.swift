//
//  SSTProgressHUD.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/19.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kActivityIndicatoryViewTag = 99999

class SSTProgressHUD {
    
    static var nWindow: UIWindow?
    
    class func getActivityIndicatorView(frameSize: CGSize? = CGSize(width:100, height: 100), bgAlpha: CGFloat? = 0.6, superV: UIView?) -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(frame: CGRect(x:0, y:0, width:validDouble(frameSize?.width), height: validDouble(frameSize?.height)))
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.backgroundColor = UIColor.black.withAlphaComponent(CGFloat(validDouble(bgAlpha)))
        activityIndicator.cornerRadius = CGFloat(validDouble(frameSize?.width)) * 0.15
        activityIndicator.startAnimating()
        activityIndicator.tag = kActivityIndicatoryViewTag
        
        if let tCenter = superV?.center {
            activityIndicator.center = tCenter
        }
        
        return activityIndicator
    }
    
    static func loadingView(view: UIView?) -> UIView? {
        return view?.viewWithTag(kActivityIndicatoryViewTag)
    }
    
    class func show(view: UIView?) {
        if view?.viewWithTag(kActivityIndicatoryViewTag) == nil {
            view?.addSubview(getActivityIndicatorView(frameSize: CGSize(width: 100 * kProkScreenWidth, height: 100 * kProkScreenWidth), superV: view))
        }
    }
    
    class func dismiss(view: UIView?) {
        UIView.animate(withDuration: 0.3, animations: {
            (view?.viewWithTag(kActivityIndicatoryViewTag) as? UIActivityIndicatorView)?.alpha = 0.01
        }) { (Bool) in
            (view?.viewWithTag(kActivityIndicatoryViewTag) as? UIActivityIndicatorView)?.removeFromSuperview()
            if validBool(nWindow?.isKeyWindow) || validBool(nWindow?.isHidden) == false {
                nWindow?.isHidden = true
                appDelegate.window?.makeKeyAndVisible()
            }
        }
    }
    
    class func showWithMaskOverFullScreen() {
        if validBool(nWindow?.isKeyWindow) == false {
            nWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
            nWindow?.windowLevel = UIWindowLevelNormal
            
            let activityIndicatorView = getActivityIndicatorView(frameSize: CGSize(width: kScreenWidth, height: kScreenHeight), bgAlpha:  0.3, superV: nWindow)
            activityIndicatorView.cornerRadius = 0
            
            nWindow?.addSubview(activityIndicatorView)
            nWindow?.makeKeyAndVisible()
        }
    }
}
