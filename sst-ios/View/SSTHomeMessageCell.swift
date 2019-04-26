//
//  SSTHomeMessageCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTHomeMessageCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    var message: SSTMessage! {
        didSet {
            titleLabel.text = message.title?.trim()
            timeLabel.text = message.createDate?.formatHMmmddyyyy()
            infoLabel.attributedText = validString(message.content).escapeHtml().toAttributedString().addFontSize(size: 13)
            
            if message.type < 0 {
                self.accessoryType = .none
            } else {
                self.accessoryType = .disclosureIndicator
            }
        }
    }
}
