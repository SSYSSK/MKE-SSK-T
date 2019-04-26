//
//  SSTBaseCell.swift
//  sst-ios
//
//  Created by Amy on 16/4/21.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTBaseCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    var itemClick: ((_ obj: AnyObject) -> Void)?
    
    @objc func clickedView(_ tap: UITapGestureRecognizer) {
        itemClick?(tap.view?.tag as AnyObject)
    }
    
}
