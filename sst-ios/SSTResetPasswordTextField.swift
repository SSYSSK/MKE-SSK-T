//
//  SSTResetPasswordTextField.swift
//  sst-ios
//
//  Created by 天星 on 17/6/17.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTResetPasswordTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.size.width - 25, height: bounds.size.height)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 10, y: bounds.origin.y, width: bounds.size.width - 25, height: bounds.size.height)
    }

}
