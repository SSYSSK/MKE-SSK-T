//
//  SSTEmptyView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/16/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTEmptyView: UIView {
    
    var refreshBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func clickedRefreshAgainButton(_ sender: Any) {
        self.refreshBlock?()
    }
}
