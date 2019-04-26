//
//  SSTOnDataView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/5.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTNoDataView: UIView {

    var reloadAgain: (() -> Void)?
    
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    
//    static func showInView(_ view:UIView, status: String, frame: CGRect?, icon: String) {
//        if frame != nil {
//            noDataView.removeFromSuperview()
//            noDataView.frame = frame!
//            noDataView.infoLabel.text = status
//            view.addSubview(noDataView)
//        } else {
//            noDataView.frame = view.frame
//            noDataView.infoLabel.text = status
//            view.addSubview(noDataView)
//        }
//    }
//    
//    static func showInController(_ controller:UIViewController, status: String, icon: String) {
//        noDataView.removeFromSuperview()
//        noDataView.frame = controller.view.frame
//        noDataView.infoLabel.text = status
//        controller.view.addSubview(noDataView)
//    }
//
//    static func dismiss(){
//        noDataView.removeFromSuperview()
//    }
//    
//    @IBAction func reloadEvent(_ sender: AnyObject) {
//        guard biz.ntwkAccess.networkIsAvailable == true else {
//            return
//        }
//        noDataView.removeFromSuperview()
//        noDataView.reloadAgain?()
//    }
}
