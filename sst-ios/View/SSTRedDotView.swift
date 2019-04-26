//
//  SSTRedDotView.swift
//  sst-ios
//
//  Created by Amy on 2017/1/18.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTRedDotView: UIView {
    
    private var numberLabel: UILabel?
    private var redImageView: UIImageView?
    
    var buyNumber: Int = 0 {
        didSet {
            if 0 == buyNumber {
                numberLabel?.text = ""
                isHidden = true
            } else {
                if buyNumber > 99 {
                    numberLabel?.font = UIFont.systemFont(ofSize: 8)
                } else {
                    numberLabel?.font = UIFont.systemFont(ofSize: 10)
                }
                
                isHidden = false
                numberLabel?.text = "\(buyNumber)"
            }
        }
    }
    
    override init(frame: CGRect) {

        super.init(frame:(CGRect(x: frame.origin.x, y: frame.origin.y, width: 15, height: 15)))
        backgroundColor = UIColor.clear
        
        redImageView = UIImageView(image: UIImage(named: "icon_reddot"))
        addSubview(redImageView!)
        
        numberLabel = UILabel()
        numberLabel?.font = UIFont.systemFont(ofSize: 10)
        numberLabel?.textColor = UIColor.white
        numberLabel?.textAlignment = NSTextAlignment.center
        addSubview(numberLabel!)
        
        isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        redImageView?.frame = bounds
        numberLabel?.frame = CGRect(x: 0, y: 0, width: width, height: height)
    }

//    func addProductToRedDotView(animation: Bool) {
//        buyNumber += 1
//        
//        if animation {
//            reddotAnimation()
//        }
//    }
//    
//    func reduceProductToRedDotView(animation: Bool) {
//        if buyNumber > 0 {
//            buyNumber -= 1
//        }
//        
//        if animation {
//            reddotAnimation()
//        }
//    }
//    
//    private func reddotAnimation() {
//        UIView.animate(withDuration: ShopCarRedDotAnimationDuration, animations: {
//            self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
//        }) { (completion) -> Void in
//            UIView.animate(withDuration: ShopCarRedDotAnimationDuration, animations: {
//                self.transform = CGAffineTransform.identity
//                }, completion: nil)
//            
//        }
//    }

}
