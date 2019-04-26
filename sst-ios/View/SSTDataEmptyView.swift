//
//  SSTEmptyView.swift
//  sst-ios
//
//  Created by Zal Zhang on 5/5/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTDataEmptyView: UIView {
    
    var buttonClick: ( () -> Void)?

    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var msgLabel: UILabel!
    @IBOutlet weak var tryAgainButton: UIButton!
    
    func setData(imgName: String = "icon_history_empty", msg: String = "Empty", buttonTitle: String = "Try Again", buttonVisible: Bool = false) {
        imgV.image = UIImage(named: imgName)
        msgLabel.text = msg
        tryAgainButton.setTitle(buttonTitle, for: .normal)
        
        if buttonVisible {
            tryAgainButton.isHidden = false
        } else {
            tryAgainButton.isHidden = true
        }
    }
    
    @IBAction func clickedButton(_ sender: Any) {
        buttonClick?()
    }
    
}
