//
//  SSTMessageBox.swift
//  sst-ios
//
//  Created by Amy on 2017/4/18.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTMessageBox: UIView {
    
    @IBOutlet weak var messageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var message: UILabel!
  
    var errorMessage: String! {
        didSet {
            let labelHeight = 60 + errorMessage.sizeByWidth(font: 13 + 2, width:  self.width / 4 * 3 - 20).height + 45 + 5
            self.message.text =  errorMessage
            self.messageViewHeightConstraint.constant =  labelHeight
        }
    }
    
    @IBAction func clickedOKAction(_ sender: AnyObject) {
        self.removeFromSuperview()
    }

    // 收起对话框
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.removeFromSuperview()
    }
    

}
