//
//  SSTToAppForCOD.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/25.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTToAppForCOD: UIView {
    
    var viewRecorsEvent: (() -> Void)?
  
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBAction func viewRecorsEvent(_ sender: AnyObject) {
        if let block = self.viewRecorsEvent {
            block()
        }
    }
}
