//
//  SSTMyPasswordVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTPasswordVC: SSTBaseVC {

    @IBOutlet weak var oldTextfield: UITextField!
    @IBOutlet weak var newTextfield: UITextField!
    @IBOutlet weak var reNewtextfield: UITextField!
    @IBOutlet weak var passwordTips: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func clickedSubmitButton(_ sender: Any) {
        let currentPassword = validString(oldTextfield.text)
        guard currentPassword.isNotEmpty else {
            SSTToastView.showError(kMoreCurrentPasswordTip)
            return
        }
        guard currentPassword.count >= 6 && currentPassword.count <= 20 else {
            SSTToastView.showError(kMoreCurrentPasswordLengthTip)
            return
        }
        let passwordStr = validString(newTextfield.text)
        guard passwordStr.count > 0 else {
            SSTToastView.showError(kMoreNewPasswordTip)
            return
        }
        guard passwordStr.count >= 6 && passwordStr.count <= 20 else {
            SSTToastView.showError(kMoreNewPasswordLengthTip)
            return
        }
        
        let passwordRepeated = validString(reNewtextfield.text)
        guard passwordRepeated == passwordStr else {
            SSTToastView.showError(kMoreRepeatedPasswordTip)
            return
        }
        
        self.view.endEditing(true)
        
        SSTProgressHUD.show(view: self.view)
        biz.user.updatePassword(currentPassword.sha512String, newPassword: passwordStr.sha512String) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                SSTToastView.showSucceed(kMoreUpdatePasswordOK)
                TaskUtil.delayExecuting(1.5, block: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
}

//MARK:-- textField delegate
extension SSTPasswordVC: UITextFieldDelegate {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
//        guard newString.characters.count < 30 else {
//            return false
//        }
//        if newTextfield.isEditing {
//            if newString.characters.count >= 6 && validInt(reNewtextfield.text?.characters.count) >= 6{
//                passwordTips.isHidden = true
//                resetBtn.isEnabled = true
//            } else {
//                passwordTips.isHidden = false
//                resetBtn.isEnabled = false
//            }
//        }
//        if reNewtextfield.isEditing {
//            if newString.characters.count >= 6 && validInt(newTextfield.text?.characters.count) >= 6 {
//                passwordTips.isHidden = true
//                resetBtn.isEnabled = true
//            } else {
//                passwordTips.isHidden = false
//                resetBtn.isEnabled = false
//            }
//            
//        }
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == oldTextfield {
            oldTextfield.resignFirstResponder()
            newTextfield.becomeFirstResponder()
        } else if textField == newTextfield {
            newTextfield.resignFirstResponder()
            reNewtextfield.becomeFirstResponder()
        } else {
            reNewtextfield.resignFirstResponder()
        }
        return true
    }
}
