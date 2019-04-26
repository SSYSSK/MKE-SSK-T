//
//  SSTErrorTipView.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/6/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTErrorTipView: UIView {

    @IBOutlet weak var msgLabel: UILabel!
    
    var message: String! {
        didSet {
            msgLabel.text = message
        }
    }
    
}
