//
//  SSTSearchViewAllWithin.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/9/20.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTSearchViewAllWithin: SSTSearchView {
    
    @IBOutlet weak var allBtn: UIButton!
    @IBOutlet weak var withinBtn: UIButton!
    
    var backFromSearchWithin: ((_ searchKey: String?) -> Void)?
    
    @IBAction func backEvent(_ sender: AnyObject) {
        self.removeFromSuperview()
        self.backFromSearch?(nil, nil)
    }
    
    @IBAction func allBtnEvent(_ sender: AnyObject) {
        self.removeFromSuperview()
        if self.backFromSearch != nil {
            self.backFromSearch!(searchTextField.text, nil)
        }
    }
    
    @IBAction func withinBtnEvent(_ sender: AnyObject) {
        self.removeFromSuperview()
        self.backFromSearchWithin?(searchTextField.text)
    }
}
