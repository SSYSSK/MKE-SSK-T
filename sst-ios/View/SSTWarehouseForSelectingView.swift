//
//  SSTWarehouseForSelectingView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/10/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

class SSTWarehouseForSelectingView: UIView {

    @IBOutlet weak var statusImgV: UIImageView!
    @IBOutlet weak var warehouseNameLabel: UILabel!
    @IBOutlet weak var stockStatusLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    @IBOutlet weak var shippingFeeLabel: UILabel!
    
    var updateWarehouse: ((_: String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(SSTWarehouseForSelectingView.tapedView))
        self.addGestureRecognizer(tap)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var warehouse: SSTWarehouse? {
        didSet {
            warehouseNameLabel.text = warehouse?.warehouseName
            stockStatusLabel.isHidden = true
            taxLabel.text = ""
            shippingFeeLabel.text = ""
        }
    }
    
    var selectedStatus: Bool? {
        didSet {
            if validBool(selectedStatus) {
                statusImgV.image = UIImage(named: "icon_choose_sel")
            } else {
                statusImgV.image = UIImage(named: "icon_choose_normal")
            }
        }
    }
    
    @objc func tapedView(sender: Any?) {
        if self.alpha > 0.9 {
            self.updateWarehouse?(validString(warehouse?.warehouseId))
        }
    }
    
}
