//
//  SSTRecordsViewCellForMe.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTRecordsViewCellForMe: UITableViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
   
    @IBOutlet weak var titleLabel: UILabel!
    var codRecord : SSTCodRecord! {
        didSet {
            remarkLabel.text = codRecord.createDate?.formatHMmmddyyyy()
            
            switch codRecord.event {
            case 0:
                titleLabel.text = "\(kCODUploadFileText):\(validString(codRecord.name))"
            case 1:
                titleLabel.text = "\(kCODDeleteFileText):\(validString(codRecord.name))"

            default:
                titleLabel.text = "\(kCODUpdateFileText):\(validString(codRecord.name))"
            }
        }
    }
}
