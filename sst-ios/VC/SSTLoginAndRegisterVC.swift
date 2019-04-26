//
//  SSTLoginAndRegisterVC.swift
//  sst-ios
//
//  Created by Amy on 16/8/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class SSTLoginAndRegisterVC: SSTBaseVC {
    
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginAndRegisterView: UIView!
    
    @IBOutlet weak var loginAndRegisterCenterConstrain: NSLayoutConstraint!
    @IBOutlet weak var loginViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginVCTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    //registerView
    @IBOutlet weak var regFirstName: UITextField!
    @IBOutlet weak var regEmail: UITextField!
    @IBOutlet weak var alternativeEmail: UITextField!
    @IBOutlet weak var regPassword: UITextField!
    @IBOutlet weak var regRePassword: UITextField!
    
    //loginView
    @IBOutlet weak var logEmail: UITextField!
    @IBOutlet weak var logPassword: UITextField!

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var leftView: UIView!
    
    @IBOutlet weak var logoImgV: UIImageView!
    @IBOutlet weak var loginAndRegisterViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var askButton: UIButton!
    
    lazy fileprivate var userInfo = SSTUser()
    fileprivate let time: TimeInterval = 3.0

    var isLogined: Bool = false
    var relogBlock:((_ isLogined: Bool) -> Void)?
    var shouldUpdateVC = false
    
    fileprivate var willNavToOtherVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginViewDisplayAndRegisterViewHidden(true)
        
        logEmail.text = biz.user.email
        
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(SSTLoginAndRegisterVC.dismissSelf))
        self.leftView.addGestureRecognizer(swipeRecognizer)
        
        IQKeyboardManager.sharedManager().enable = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if willNavToOtherVC {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        willNavToOtherVC = false
        super.viewWillDisappear(animated)
        
        relogBlock?(isLogined)
        gLoginVC = nil
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    @objc func dismissSelf(swipeRecognizer: UISwipeGestureRecognizer) {
        if swipeRecognizer.direction == .right {
            self.dismiss(animated: true)
        }
    }
    
    // 收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        if shouldUpdateVC == true {
            shouldUpdateVC = false
            loginAndRegisterViewTopConstraint.constant = 226
            logoImgV.isHidden = false
        }
    }
    
    //back event
    @IBAction func clickedBackEvent(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:-- 登陆按钮点击事件
    @IBAction func clickedSignInEvent(_ sender: AnyObject) {
        
        let email = validString(logEmail.text).trim()
        let logPS = validString(logPassword.text).trim()
        
        if email.isEmpty && logPS.isEmpty {
            logEmail.becomeFirstResponder()
            SSTToastView.showError(kEmailAndPasswordAllEmptyTip)
            return
        } else if email.isEmpty {
            logEmail.becomeFirstResponder()
            SSTToastView.showError(kMoreEmptyEmailTip)
            return
        } else if !email.isValidEmail {
            logEmail.becomeFirstResponder()
            SSTToastView.showError(kMoreInvalidEmailTip)
            return
        } else if logPS.isEmpty {
            logPassword.becomeFirstResponder()
            SSTToastView.showError(kMorePasswordTip)
            return
        }
        
        userInfo.email = email
        userInfo.password = validString(logPassword.text?.sha512String)
        userInfo.token = biz.user.token
        
        SSTProgressHUD.show(view: self.view)
        biz.user.login(userInfo) { [weak self] (data, error) in
            SSTProgressHUD.dismiss(view: self?.view)
            if error == nil {
                self?.isLogined = true
                
                // if current user is different, then refresh the vc related to user
                if biz.user.id != biz.oldUserId {
                    if let childControllers = gMainTC?.childViewControllers as? [UINavigationController] {
                        for nc in childControllers {
                            for vc in nc.childViewControllers {
                                if vc.responds(to: #selector(SSTMoreVC.resetViewAfterLoginedByAnotherAccount)) {
                                    vc.perform(#selector(SSTMoreVC.resetViewAfterLoginedByAnotherAccount))
                                }
                            }
                        }
                    }
                }
                
                biz.oldUserId = validString(biz.user.id)
                
                self?.dismiss(animated: false, completion: nil)
                SSTItemData.getStockNotifications()
            } else {
                SSTToastView.showError(validString((error! as AnyObject).debugDescription))
            }
        }
    }

    //MARK:-- 注册按钮点击事件
    @IBAction func clickedRegisterEvent(_ sender: AnyObject) {
        if registerView.isHidden == true {
            loginViewDisplayAndRegisterViewHidden(false)
        } else {
            let firstName = validString(regFirstName.text)
            guard firstName.count >= 1 && firstName.count <= 30 else {
                SSTToastView.showError(kMoreFirstNameLengthTip)
                regFirstName.becomeFirstResponder()
                return
            }
            
            let email = validString(regEmail.text)
            guard email.isValidEmail else {
                SSTToastView.showError(kMoreInvalidEmailTip)
                regEmail.becomeFirstResponder()
                return
            }
            let altEmail = validString(alternativeEmail.text)
            
            guard altEmail.isValidEmail || altEmail.isEmpty else {
                SSTToastView.showError(kMoreInvalidEmailTip)
                alternativeEmail.becomeFirstResponder()
                return
            }
            
            let password = validString(regPassword.text)
            guard password.count >= 6 && password.count <= 20 else {
                SSTToastView.showError(kMorePasswordLengthTip)
                regPassword.becomeFirstResponder()
                return
            }
            
            let repeatedPassword = validString(regRePassword.text)
            guard repeatedPassword == password else {
                SSTToastView.showError(kMoreRepeatedPasswordTip)
                regRePassword.becomeFirstResponder()
                return
            }
            
            userInfo.firstName = firstName
            userInfo.email = email
            userInfo.alternativeEmail = altEmail
            userInfo.password = validString(password.sha512String)
            userInfo.token = biz.user.token
            
            SSTProgressHUD.show(view: self.view)
            SSTUser.register(userInfo, callback: { data, error in
                SSTProgressHUD.dismiss(view: self.view)
                if error == nil {
                    SSTToastView.showSucceed(kMoreRegistrationOK)
                    self.isLogined = true
                    
                    TaskUtil.delayExecuting(0.5, block: {
                        self.dismiss(animated: false, completion: nil)
                    })
                } else {
                    SSTToastView.showError(validString(error))
                }
            })
        }
    }

    //MARK:--点击疑问按钮时间
    @IBAction func clickedDoubtEvent(_ sender: Any) {
        let errorMessageView = loadNib("\(SSTDoubtMessage.classForCoder())") as! SSTDoubtMessage
        errorMessageView.frame = UIScreen.main.bounds
        let arrorX = askButton.absoluteX + 2
        let aroorY = (alternativeEmail.superview?.y)! + (alternativeEmail.superview?.superview?.y)! + alternativeEmail.frame.origin.y + 33
        errorMessageView.setFrame(arrorX: arrorX, arrorY: aroorY, messageLeading: 30, messageTrailing: 20, messageStr: kAlternativeEmailInfomation)
        getTopWindow()?.addSubview(errorMessageView)
    }
    
    //MARK:-- 忘记密码按钮点击事件
    @IBAction func clickedForgetPasswordEvent(_ sender: AnyObject) {
        self.performSegueWithIdentifier(.SegueToForgotVC, sender: nil)
    }
   
    //MARK:-- 在注册页面中点击登陆
    @IBAction func signInEventInRegisterView(_ sender: AnyObject) {
        loginViewDisplayAndRegisterViewHidden(true)
    }
    
    fileprivate func loginViewDisplayAndRegisterViewHidden(_ display: Bool) {
        //UIView.animateWithDuration(0.25) {
            self.titleLabel.text = display ? "Sign In" : "Register"
            self.loginView.isHidden = !display
            self.registerView.isHidden = display
            let imageName = display ? kLoginButtonNormalImgName : kLoginButtonSelectedImgName
            self.registerBtn.setBackgroundImage(UIImage(named: imageName), for: UIControlState())
            self.view.layoutIfNeeded()
        //}
    }
}

extension SSTLoginAndRegisterVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.regFirstName || textField == self.regEmail || textField == self.alternativeEmail {
            let toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
            if toBeString.count > 50 {
                return false
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if shouldUpdateVC == false {
            shouldUpdateVC = true
            loginAndRegisterViewTopConstraint.constant = 70
            logoImgV.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == logEmail {
            let email = validString(textField.text)
            if email.isValidEmail {
                logEmail.resignFirstResponder()
                logPassword.becomeFirstResponder()
            } else {
                logEmail.resignFirstResponder()
                SSTToastView.showError(kMoreInvalidEmailTip)
            }
        } else if textField == logPassword {
            textField.resignFirstResponder()
            
            //登录逻辑代码
            self.clickedSignInEvent(NSNull.classForCoder())
        }
        
        
        if textField == regFirstName {
            regFirstName.resignFirstResponder()
            regEmail.becomeFirstResponder()
        } else if textField == regEmail {
            let email = validString(textField.text)
            if email.isValidEmail {
                regEmail.resignFirstResponder()
                alternativeEmail.becomeFirstResponder()
                return true
            } else {
                SSTToastView.showError(kMoreInvalidEmailTip)
            }
        } else if textField == alternativeEmail{
            let altEmail = validString(textField.text)
            if altEmail.isValidEmail {
                alternativeEmail.resignFirstResponder()
                regPassword.becomeFirstResponder()
                return true
            } else {
                SSTToastView.showError(kMoreInvalidEmailTip)
            }
            
        } else if textField == regPassword {
            let rePassword = validString(textField.text)
            if rePassword.count >= 6 && rePassword.count <= 20 {
                regPassword.resignFirstResponder()
                regRePassword.becomeFirstResponder()
            } else {
                SSTToastView.showError(kMorePasswordLengthTip)
            }
        } else if textField == regRePassword {
            if regRePassword.text == regPassword.text {
                textField.resignFirstResponder()
                
                //注册逻辑代码
                self.clickedRegisterEvent(NSNull.classForCoder())
                
            } else {
                SSTToastView.showError(kMoreRepeatedPasswordTip)
                return false
            }
        }
        
        return true
    }
}

extension SSTLoginAndRegisterVC:SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToForgotVC    = "ToForgotVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.willNavToOtherVC = true
        
        switch segueIdentifierForSegue(segue) {
        case .SegueToForgotVC:
            let destVC = segue.destination as! SSTForgotPasswordVC
            destVC.emailStr = logEmail.text
        }
    }
}
