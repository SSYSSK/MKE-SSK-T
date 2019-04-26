//
//  SSTForgotPasswordVC.swift
//  sst-ios
//
//  Created by Amy on 16/9/12.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTForgotPasswordVC: SSTBaseVC {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var verCode: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var rePassword: UITextField!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var sendCodeMessage: UILabel!
    
    var emailStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email.text = emailStr
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        super.viewWillAppear(animated)
    }

    @IBAction func clickedSendCodeEvent(_ sender: AnyObject) {
        if let emailstr = email.text  {
            guard emailstr.isNotEmpty else {
                SSTToastView.showError(kMoreEmptyEmailTip)
                return
            }
            guard emailstr.isValidEmail else {
                SSTToastView.showError(kMoreInvalidEmailTip)
                return
            }
            
            SSTProgressHUD.show(view: self.view)
            biz.user.getVerification(emailstr, callback: { (message) in
                SSTProgressHUD.dismiss(view: self.view)
                if validInt(message) == 200 {
                    self.sendCodeMessage.text = kSendCodeMessage
                    SSTToastView.showSucceed(kMoreSendVerificationCodeTip)
                    self.sendBtn.isEnabled = false
                } else {
                    SSTToastView.showError(validString(message))
                }
            })
        }
    }
    
    @IBAction func clickedConfirmEvent(_ sender: AnyObject?) {
        let emailstr = validString(email.text)
        guard emailstr.isNotEmpty else {
            SSTToastView.showError(kMoreEmptyEmailTip)
            return
        }
        guard emailstr.isValidEmail else {
            SSTToastView.showError(kMoreInvalidEmailTip)
            return
        }
        
        guard validInt(verCode.text?.count) > 0 else {
            SSTToastView.showError(kMoreEmptyVerificationCodeTip)
            return
        }
        
        let passwordStr = validString(newPassword.text)
        guard passwordStr.count > 0 else {
            SSTToastView.showError(kMoreNewPasswordTip)
            return
        }
        guard passwordStr.count >= 6 && passwordStr.count <= 20 else {
            SSTToastView.showError(kMoreNewPasswordLengthTip)
            return
        }
        
        guard validString(rePassword.text) == passwordStr else {
            SSTToastView.showError(kMoreRepeatedPasswordTip)
            return
        }
        
        let newPasswordEncryp = validString(newPassword.text?.sha512String)
        
        SSTProgressHUD.show(view: self.view)
        biz.user.updatePasswordByVerificationCode(emailstr, password: newPasswordEncryp, code: validString(verCode.text)) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                SSTToastView.showSucceed(kMoreResetPasswordOK)
                TaskUtil.delayExecuting(0.5, block: {
                    self.dismiss(animated: false, completion: nil)
                })
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
}

extension SSTForgotPasswordVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == email {
            email.resignFirstResponder()
            verCode.becomeFirstResponder()
        } else if textField == verCode {
            verCode.resignFirstResponder()
            newPassword.becomeFirstResponder()
        } else if textField == newPassword {
            newPassword.resignFirstResponder()
            rePassword.becomeFirstResponder()
        } else if textField == rePassword {
           self.clickedConfirmEvent(nil)
        }
        return true
    }
}
