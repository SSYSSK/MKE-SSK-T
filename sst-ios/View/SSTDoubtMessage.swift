//
//  SSTDoubtMessage.swift
//  sst-ios
//
//  Created by Amy on 2017/9/19.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTDoubtMessage: UIView {

    @IBOutlet weak var arror: UIImageView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var message: UILabel!
    
    func setFrame(arrorX: CGFloat, arrorY: CGFloat, messageLeading: CGFloat, messageTrailing: CGFloat, messageStr: String) {
        arror.frame = CGRect(x: arrorX, y: arrorY, width: 15, height: 12)
        
        let messageviewHeight = 10 + messageStr.sizeByWidth(font: 13 + 2, width: self.width - messageLeading - messageTrailing).height
        messageView.frame = CGRect(x: messageLeading, y: arror.y + arror.height, width: kScreenWidth - messageLeading - messageTrailing, height: messageviewHeight)
        messageView.layer.cornerRadius = 5
        
        message.frame = CGRect(x: 10, y: 5, width: messageView.width - 15, height: messageView.height - 5)
        message.text = messageStr
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }

}
