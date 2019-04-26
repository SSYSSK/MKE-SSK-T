//
//  SSTAppForCODFail.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/25.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTAppForCODFail: UIView {

    @IBOutlet weak var iconImge: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    var viewRecorsEvent: (() -> Void)?

    @IBAction func viewResors(_ sender: AnyObject) {
        if let block = self.viewRecorsEvent {
            block()
        }
    }
}
