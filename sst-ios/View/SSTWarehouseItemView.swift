//
//  SSTWarehouseItemView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/9/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

let kPopViewWidth: CGFloat = 150

let kPopViewButtonHeight: CGFloat = 40
let kPopViewUpdateWarehouseButtonWidth: CGFloat = 170

class SSTWarehouseItemView: SSTItemBaseView {
    
    var usableWarehouses: [SSTWarehouse]?
    
    var itemPriceLabel : UILabel!
    var qtyLabel: UILabel!
    var totalLabel: UILabel!
    
    var deleteButton: UIButton!
    var updateWarehouseButton: UIButton!
    
    var orderItem: SSTOrderItem! {
        didSet {
            self.item = orderItem
            setViewFrame(layout: .list)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        totalLabel = UILabel(frame: CGRect(x: imgV.width + 205, y: 30, width: kScreenWidth, height: self.frame.height - 40))
        totalLabel.font = UIFont.boldSystemFont(ofSize: 11)
        totalLabel.minimumScaleFactor = 0.5
        totalLabel.adjustsFontSizeToFitWidth = true
        totalLabel.textAlignment = .right
        totalLabel.textColor = UIColor.orange
        self.addSubview(totalLabel)
        
        updateWarehouseButton = UIButton(frame: CGRect(x: kScreenWidth - 10 - kPopViewUpdateWarehouseButtonWidth, y: totalLabel.y + 55, width: kPopViewUpdateWarehouseButtonWidth, height: 30))
        updateWarehouseButton.setTitle("Change shipping from ", for: UIControlState.normal)
        updateWarehouseButton.setImage(UIImage(named:"icon_changeWarehouse"), for: UIControlState.normal)
        updateWarehouseButton.imageEdgeInsets = UIEdgeInsets(top: -1, left: 158, bottom: -1, right: -5)
        updateWarehouseButton.setTitleColor(kItemNameLabelColor, for: .normal)
        updateWarehouseButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.addSubview(updateWarehouseButton)
        
        deleteButton = UIButton(frame: CGRect(x: updateWarehouseButton.x - 50, y: updateWarehouseButton.y, width: 40, height: 30))
        deleteButton.setImage(UIImage(named: "icon_address_delete"), for: UIControlState.normal)
        deleteButton.setTitle("del", for: UIControlState.normal)
        deleteButton.setTitleColor(kItemNameLabelColor, for: .normal)
        deleteButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        self.addSubview(deleteButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setViewFrame(layout: SearchResultLayoutStyle = .grid) {
        super.setViewFrame(layout: layout)
        
        nameLabel.numberOfLines = 2
        totalLabel.frame = CGRect(x: nameLabel.x, y: 30, width: kScreenWidth - nameLabel.x - 20, height: self.frame.height - 40)
        updateWarehouseButton.frame = CGRect(x: kScreenWidth - 20 - kPopViewUpdateWarehouseButtonWidth,
                                             y: totalLabel.y + 45 * kProkScreenHeight,
                                         width: kPopViewUpdateWarehouseButtonWidth,
                                        height: 30)
        deleteButton.frame = CGRect(x: updateWarehouseButton.x - 40, y: updateWarehouseButton.y, width: 40, height: updateWarehouseButton.height)
    }
    
}
