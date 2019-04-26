//
//  SSTContactSSTCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/19/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTContactSSTCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var msgCntLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var redDotImgV: UIImageView!

    var record: SSTContactRecord? {
        didSet {
            idLabel.text = record?.id
            titleLabel.text = record?.title
            dateLabel.text = record?.dateCreated?.formatHMmmddyyyy()
            statusLabel.text = record?.statusText
            
            if validInt(record?.msgCnt) > 0 {
                redDotImgV.isHidden = false
                msgCntLabel.isHidden = false
                msgCntLabel.text = validString(record?.msgCnt)
            } else {
                redDotImgV.isHidden = true
                msgCntLabel.isHidden = true
            }
            
            dateLabel.text = validDate(record?.dateCreated).formatHMmmddyyyy()
        }
    }

}
