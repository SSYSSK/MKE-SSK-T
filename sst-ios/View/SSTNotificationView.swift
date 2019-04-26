//
//  SSTNotificationView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/10.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

enum NotificationStatusType: String {
    case show = "showNotification"
    case hidden = "hiddenNotification"
}

class SSTNotificationView: UIView {
    
    var notificationClick: ((_ status: NotificationStatusType? , _ view: UIView) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        let imageViewBg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageViewBg.image = UIImage(named: "home_message_bg")
        self.addSubview(imageViewBg)
        
        let topImageView = UIImageView(frame: CGRect(x: (self.frame.width - 90 * kProkScreenWidth) / 2 , y: 30, width: 90 * kProkScreenWidth, height: 45 * kProkScreenWidth))
        topImageView.image = UIImage(named: "home_message_logo")
        self.addSubview(topImageView)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: topImageView.frame.maxY + 30 * kProkScreenWidth, width: self.frame.width, height: 20))
        titleLabel.text = "Enable Notifications"
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.sizeToFit()
        titleLabel.center.x = self.frame.width/2
        self.addSubview(titleLabel)
        
        let dealsLabelImage = UIImageView(frame: CGRect(x: titleLabel.frame.origin.x, y: titleLabel.frame.maxY + 16 * kProkScreenWidth, width: 16, height: 16))
        dealsLabelImage.image = UIImage(named: "home_deals")
        self.addSubview(dealsLabelImage)
        
        let dealsLabel = UILabel(frame: CGRect(x: dealsLabelImage.frame.maxX + 5, y: titleLabel.frame.maxY + 14 * kProkScreenWidth, width: self.frame.width, height: 20))
        dealsLabel.text = "Deals and promotions"
        dealsLabel.textColor = RGBA(59, g: 59, b: 59, a: 1)
        dealsLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.sizeToFit()
        self.addSubview(dealsLabel)
        
        let orderLabelImage = UIImageView(frame: CGRect(x: titleLabel.frame.origin.x, y: dealsLabel.frame.maxY + 10 * kProkScreenWidth, width: 16, height: 16))
        orderLabelImage.image = UIImage(named: "home_order")
        self.addSubview(orderLabelImage)
        
        let orderLabel = UILabel(frame: CGRect(x: orderLabelImage.frame.maxX + 5, y: dealsLabel.frame.maxY + 10 * kProkScreenWidth, width: self.frame.width, height: 20))
        orderLabel.text = "Order status"
        orderLabel.textColor = RGBA(59, g: 59, b: 59, a: 1)
        orderLabel.font = UIFont.systemFont(ofSize: 14)
        orderLabel.sizeToFit()
        self.addSubview(orderLabel)
        
        let remindersLabelImage = UIImageView(frame: CGRect(x: titleLabel.frame.origin.x, y: orderLabel.frame.maxY+10*kProkScreenWidth, width: 16, height: 16))
        remindersLabelImage.image = UIImage(named: "home_reminders")
        self.addSubview(remindersLabelImage)
        
        let remindersLabel = UILabel(frame: CGRect(x: remindersLabelImage.frame.maxX+5, y:  orderLabel.frame.maxY+10*kProkScreenWidth, width: self.frame.width, height: 20))
        remindersLabel.text = "Reminders"
        remindersLabel.textColor = RGBA(59, g: 59, b: 59, a: 1)
        remindersLabel.font = UIFont.systemFont(ofSize: 14)
        remindersLabel.sizeToFit()
        self.addSubview(remindersLabel)
        
        
        let lineView = UIView(frame: CGRect(x: 0, y: self.frame.height-45, width: self.frame.width, height: 1))
        lineView.backgroundColor = RGBA(207, g: 207, b: 207, a: 0.5)
        self.addSubview(lineView)
        
        let noButton = UIButton(frame: CGRect(x: 0, y: lineView.frame.maxY, width: self.frame.width/2-0.5, height: 44))
        noButton.setTitleColor(UIColor.blue, for: UIControlState())
        noButton.setTitle("Later", for: UIControlState())
        self.addSubview(noButton)
        noButton.addTarget(self, action: #selector(SSTNotificationView.noButtonEvent), for: UIControlEvents.touchUpInside)
        noButton.setTitleColor(RGBA(29, g: 157, b: 255, a: 1), for: UIControlState())
        
        let lineView2 = UIView(frame: CGRect(x: noButton.frame.maxX, y: lineView.frame.maxY, width: 1, height: 44))
        lineView2.backgroundColor = RGBA(207, g: 207, b: 207, a: 0.5)
        self.addSubview(lineView2)
        
        let okButton = UIButton(frame: CGRect(x:self.frame.width/2+0.5, y: lineView.frame.maxY, width: self.frame.width/2-0.5, height: 44))
        okButton.addTarget(self, action: #selector(SSTNotificationView.okButtonEvent), for: UIControlEvents.touchUpInside)
        okButton.setTitle("OK", for: UIControlState())
        okButton.setTitleColor(RGBA(29, g: 157, b: 255, a: 1), for: UIControlState())
        self.addSubview(okButton)
    }
    
    @objc func noButtonEvent() {
        self.removeFromSuperview()
        self.notificationClick?(NotificationStatusType.hidden, self)
    }
    
    @objc func okButtonEvent() {
        self.removeFromSuperview()
        self.notificationClick?(NotificationStatusType.show, self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
