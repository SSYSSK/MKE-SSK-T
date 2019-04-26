//
//  SSTSearchWindow.swift
//  sst-ios
//
//  Created by Zal Zhang on 3/28/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTSearchWindow: UIWindow {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    fileprivate static var searchWindow: UIWindow?
    static var searchV: SSTSearchView?
    
    static func show() {
        let searchWindowHeight = kScreenHeight
        
        searchWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: searchWindowHeight))
        searchWindow?.windowLevel = UIWindowLevelNormal
        searchWindow?.backgroundColor = RGBA(245, g: 245, b: 245, a: 1)
        
        searchV = loadNib("\(SSTSearchView.classForCoder())") as? SSTSearchView
        searchV?.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: searchWindowHeight)
        if let tmpV = searchV {
            searchWindow?.addSubview(tmpV)
        }
        
        searchWindow?.makeKeyAndVisible()
    }
    
    static func hide() {
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

}
