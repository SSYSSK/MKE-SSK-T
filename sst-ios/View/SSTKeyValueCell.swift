//
//  SSTKeyValueCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/14.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTKeyValueCell: UITableViewCell {

    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setFacet(facet: Facet) {
        keyLabel.text = clearName("\(facet.key)")
        keyLabel.font = UIFont.systemFont(ofSize: 13)
        keyLabel.textColor = UIColor.black
        countLabel.text = "(\(facet.value))"
        countLabel.isHidden = false
        icon.isHidden = true
    }
    
    func setCategoryFacet(facet: Facet) {
        var keyValue = facet.key
        if facet.type != "group" {
            if keyValue.contains("$$$") {
                keyValue = validString(facet.key.components(separatedBy: "$$$").validObjectAtIndex(1))
            }
            keyLabel.font = UIFont.systemFont(ofSize: 11)
            keyLabel.textColor = UIColor.gray
        } else {
            keyLabel.font = UIFont.systemFont(ofSize: 13)
            keyLabel.textColor = UIColor.black
        }
        
        keyLabel.text = (facet.type == "group" ? "" : "     ") + clearName("\(keyValue)")
        countLabel.text = "(\(facet.value))"
        countLabel.isHidden = facet.type == "group"
        icon.isHidden = facet.type != "group"
        setIconImgView(isExpanded: facet.isExpanded)
    }
    
    func setIconImgView(isExpanded: Bool) {
        icon.image = UIImage(named: isExpanded ? "result_icon_up" : "result_icon_down")
    }
}
