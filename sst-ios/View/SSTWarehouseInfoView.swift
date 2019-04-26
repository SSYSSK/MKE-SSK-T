//
//  SSTWarehouseInfoView.swift
//  sst-ios
//
//  Created by Amy on 2017/12/27.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTWarehouseInfoView: UIView {

    var deleteNoticeBlock:(() ->Void)?
    
    @IBAction func deleteNoticeAction(_ sender: Any) {
        if let block = deleteNoticeBlock {
            block()
        }
    }
    
}
