//
//  SSTSearchTextField.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/18/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTSearchTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x+33, y: bounds.origin.y, width: bounds.size.width-55, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x+33, y: bounds.origin.y, width: bounds.size.width-55, height: bounds.size.height)
    }
    
}
