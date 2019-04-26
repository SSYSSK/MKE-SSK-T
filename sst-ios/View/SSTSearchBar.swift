//
//  SSTSearchBar.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/1/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTSearchBar: UISearchBar {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.placeholder = "search"
        
        for view in self.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UITextField.classForCoder()) {
                    let tField = subview as! UITextField
                    tField.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.3)
                    tField.textColor = UIColor.black
                    tField.tintColor = UIColor.black
                    tField.layer.cornerRadius = 2
                    tField.layer.borderWidth = 0
                } else {
                    if let searchBarBackgroundClass = NSClassFromString("UISearchBarBackground") {
                        if subview.isKind(of: searchBarBackgroundClass) {
                            subview.removeFromSuperview()
                            continue
                        }
                    }
                    if let navigationButtonClass = NSClassFromString("UINavigationButton") {
                        if subview.isKind(of: navigationButtonClass) {
                            let tButton = subview as! UIButton
                            tButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
                            continue
                        }
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.placeholder = kSearchBarPlaceholderText
        self.barTintColor = UIColor.red
        
        for view in self.subviews {
            for subview in view.subviews {
                if subview.isKind(of: UITextField.classForCoder()) {
                    let tField = subview as! UITextField
                    tField.backgroundColor = UIColor.white
                    tField.textColor = UIColor.black
                    tField.tintColor = UIColor.black
                    tField.layer.cornerRadius = 2
                }
                if let searchBarBackgroundClass = NSClassFromString("UISearchBarBackground") {
                    if subview.isKind(of: searchBarBackgroundClass) {
                        subview.removeFromSuperview()
                        continue
                    }
                }
            }
        }
        
        self.contentInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    var contentInset: UIEdgeInsets? {
        didSet {
            self.layoutSubviews()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in self.subviews { // view is only one sub-element of searchBar
            for subview in view.subviews {  // UISearchBarBackground and UISearchBarTextField is the second level sub-element of searchBar
                
                if subview.isKind(of: UITextField.classForCoder()) {
                    if let tContentInset = contentInset {
                        subview.frame = CGRect(x: tContentInset.left, y: tContentInset.top, width: self.bounds.width-tContentInset.left, height: self.bounds.height - tContentInset.top)
                    } else {
                        let top: CGFloat = (self.bounds.height - 28.0) / 2.0 + 3
                        let bottom: CGFloat = top
                        let left: CGFloat = 8.0
                        let right: CGFloat = left
                        contentInset = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
                    }
                }
            }
        }
    }
    
}
