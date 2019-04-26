//
//  SSTOrderDetailSubtotalCell.swift
//  sst-ios
//
//  Created by 天星 on 2018/1/5.
//  Copyright © 2018年 ios. All rights reserved.
//

import UIKit

class SSTOrderDetailSubtotalCell: UITableViewCell {

    @IBOutlet weak var finalPrice: UILabel!
    
    @IBOutlet weak var price: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
