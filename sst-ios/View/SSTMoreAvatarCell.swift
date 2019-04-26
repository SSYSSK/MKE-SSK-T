//
//  SSTMoreAvatarCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTMoreAvatarCell: SSTBaseCell {

    @IBOutlet weak var firstName: UILabel!
    @IBOutlet weak var userID: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    var clickedLoginBlock:(() -> Void)?
    
    @IBAction func clickedLoginAction(_ sender: AnyObject) {
        if let block = clickedLoginBlock {
            block()
        }
    }
}
