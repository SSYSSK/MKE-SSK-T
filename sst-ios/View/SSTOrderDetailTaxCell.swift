//
//  SSTOrderDetailTaxCell.swift
//  sst-ios
//
//  Created by 天星 on 2018/1/4.
//  Copyright © 2018年 ios. All rights reserved.
//

import UIKit

class SSTOrderDetailTaxCell: UITableViewCell {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
