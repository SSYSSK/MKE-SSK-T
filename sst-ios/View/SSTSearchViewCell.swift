//
//  SSTSearchViewCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/8/29.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTSearchViewCell: UITableViewCell {
    
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var nameL: UILabel!

    var name: String? {
        didSet {
            if let name = name{
                nameL.text = name
            }
        }
    }
}
