//
//  SSTToastView.swift
//  sst-ios
//
//  Created by Amy on 2016/12/26.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kToastViewBackgroundColor = UIColor(red: 169/255.0, green: 169/255.0, blue: 169/255.0, alpha: 1)

class SSTToastView: UIView {
    
    var msgLabel: UILabel!
    var iconImage: UIImageView!
    
    var dismissTask: AsynTask?
    
    static var appWindow: UIWindow! {
        get {
            var applicationKeyWindow:UIWindow! = nil
            let frontToBackWindows = UIApplication.shared.windows.reversed()
            for window in frontToBackWindows {
                if window.windowLevel == UIWindowLevelNormal {
                    applicationKeyWindow = window
                    break
                }
            }
            if applicationKeyWindow == nil {
                return nil
            }
            return applicationKeyWindow
        }
    }

    static var sToastView: SSTToastView?
    
    init() {
        super.init(frame: CGRect(x: 0, y: -64, width: kScreenWidth, height: 40))
        
        iconImage = UIImageView(frame: CGRect(x: 15, y: kScreenNavigationHeight - 34, width: 19, height: 19))
        iconImage.image = UIImage(named: "icon_success")
        self.addSubview(iconImage)
        
        msgLabel = UILabel(frame: CGRect(x: iconImage.center.x + 15, y: iconImage.y + 1, width: kScreenWidth - iconImage.width - 30, height: 0))
        msgLabel.textColor = UIColor.white
        msgLabel.numberOfLines = 0
        msgLabel.font = UIFont.systemFont(ofSize: 13)
        msgLabel.lineBreakMode = .byWordWrapping
        msgLabel.textAlignment = .left
        self.addSubview(msgLabel)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        self.addGestureRecognizer(tapAction)
        
        let swipRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(doAfterSwipe))
        self.addGestureRecognizer(swipRecognizer)
        
        self.backgroundColor = kToastViewBackgroundColor
        self.alpha = 0.01
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    class func showSucceed(_ msg: String) {
        self.show(msg, icon: "icon_success", top: 0)
    }
    
    class func showInfo(_ msg: String) {
        self.show(msg, icon: "icon_info", top: 0)
    }

    
    class func showError(_ msg: String) {
        let message = msg
        if message.count <= 0 {
            return
        }
        if biz.ntwkAccess.networkIsAvailable {
            self.show(message, icon: "icon_failed", top: 0)
        }
    }
     
    class func showErrorNetworkConnect(_ msg: String) {
        var message = msg
        if message.count <= 0 {
            message = kBadConnectedMessage
        }
        self.show(message, icon: "icon_wifi", top: 0)
    }
  
    class func show(_ msg: String, icon: String, top: CGFloat) {
        
        guard let win = getTopWindow() else {
            ToastUtil.showToast(msg)
            return
        }
        
        sToastView?.dismiss()
        
        let toastView = SSTToastView()
        win.addSubview(toastView)
        
        toastView.iconImage.image = UIImage(named: icon)

        let msgHeight = msg.sizeByWidth(font: 13, width: toastView.msgLabel.width).height
        
        toastView.msgLabel.text = msg
        toastView.msgLabel.frame.size = CGSize(width: toastView.msgLabel.size.width, height: msgHeight)
        
        let viewHeight = msgHeight + kScreenNavigationHeight - 24
        toastView.frame = CGRect(x: 0, y: -64, width: kScreenWidth, height: viewHeight < kScreenNavigationHeight ? kScreenNavigationHeight : viewHeight )
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromTop, animations: { () -> Void in
            var frame = toastView.frame
            frame.origin.y = 0
            toastView.frame = frame
            toastView.alpha = 1
        }) { (finished) -> Void in
            let delay = 1 + validDouble(msg.sizeByWidth(font: 13, width: kScreenWidth).height / 10)
            let time = DispatchTime.now() + delay
            DispatchQueue.main.asyncAfter(deadline: time) {
                toastView.dismiss()
            }
        }
        
        sToastView = toastView
    }

    @objc func dismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.transitionFlipFromBottom, animations: { () -> Void in
            var frame = self.frame
            frame.origin.y = -64
            self.frame = frame
            self.alpha = 0.01
        }) { (finished) -> Void in
            self.removeFromSuperview()
        }
    }
    
    @objc func doAfterSwipe(recognizer: UISwipeGestureRecognizer) {
        self.dismiss()
    }
}
