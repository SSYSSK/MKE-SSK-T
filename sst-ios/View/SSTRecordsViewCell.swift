//
//  SSTRecordsViewCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTRecordsViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var remark: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

//    let kCODRejectedText = "Application Rejected" // 失败
//    let kCODApprovedText = "Application Approved" // 通过
//    let kCODDeniedText = "Application Pending" // 审核中
    
    var codRecord : SSTCodRecord! {
        didSet {
            timeLabel.text = codRecord.createDate?.formatHMmmddyyyy()
            
            remark.text = codRecord.remarks
            switch codRecord.applystatus {
            case 0:
                titleLabel.text = kCODDeniedText
            case 1:
                titleLabel.text = kCODApprovedText
            case 2:
                titleLabel.text = kCODRejectedText
            case -1:
                titleLabel.text = kCODInvalidText
            default:
                titleLabel.text = ""
            }
        }
    }
}
