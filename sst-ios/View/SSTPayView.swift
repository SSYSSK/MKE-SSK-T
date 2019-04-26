//
//  SSTPayView.swift
//  sst-ios
//
//  Created by Amy on 16/8/30.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

protocol  SSTCheckOutDelegate: class {
    func clickedCheckOutButton()
}

class SSTPayView: UIView {
   
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var oldPayCount: UILabel!
    @IBOutlet weak var count: UILabel! //saved price
    
    weak var delegate: SSTCheckOutDelegate?
    
    func setData(_ total: Double, oldAmount: Double, count: Int) {
        self.total.text = total.formatC()
        
        if oldAmount - total > kOneInMillion {
            self.oldPayCount.isHidden = false
            self.oldPayCount.text = oldAmount.formatC()
        } else {
            self.oldPayCount.isHidden = true
            self.oldPayCount.text = ""
        }
        
        let savedPrice = oldAmount - total
        if savedPrice > kOneInMillion {
            self.count.isHidden = false
            self.count.text = "Save \(savedPrice.formatC())"
        } else {
            self.count.isHidden = true
            self.count.text = ""
        }
    }
    
    @IBAction func clickedCheckoutEvent(_ sender: AnyObject) {
        delegate?.clickedCheckOutButton()
    }
}
