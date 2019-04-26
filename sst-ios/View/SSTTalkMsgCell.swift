//
//  SSTContactMsgView.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTTalkMsgCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    
    var record: SSTContactRecord? {
        didSet {
            contentLabel.text = record?.title
        }
    }
    
    var reply: SSTContactReply? {
        didSet {
            contentLabel.text = reply?.content
        }
    }

}
