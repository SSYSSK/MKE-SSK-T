//
//  SSTNewsListCell.swift
//  sst-ios
//
//  Created by Amy on 16/4/21.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTHomeNewsCell: UITableViewCell {

    @IBOutlet weak var newsTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ dataArray: NSArray) {
        if dataArray.firstObject != nil {
//            newsTitle.text = (dataArray.firstObject as! SSTNews).articleTitle
        }
    }

}
