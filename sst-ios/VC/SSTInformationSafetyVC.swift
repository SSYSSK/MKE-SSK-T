//
//  SSTInformationSafetyVC.swift
//  sst-ios
//
//  Created by Amy on 16/9/12.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTInformationSafetyVC: SSTBaseTVC {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UILabel!
    
    @IBOutlet weak var alternativeTitle: UILabel!
    @IBOutlet weak var alternativeEmail: UITextField!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var askButton: UIButton!
    
    enum SegueIdentifier: String {
        case toChangePassword           = "toChangePassword"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshView()
    }
    
    func refreshView() {
        name.text = biz.user.firstName
        email.text = biz.user.email
        alternativeEmail.text = biz.user.alternativeEmail
        userId.text = biz.user.guid
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.refreshView()
    }
    
    fileprivate func modifyFirstNameEvent() {
        SSTProgressHUD.show(view: self.view)
        biz.updateFirstName(validString(name.text)) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if data != nil {
                if let user: SSTUser = SSTUser(JSON: validDictionary(data)) {
                    user.type = true
                    biz.user = user
                    FileOP.archive(kUserFileName, object: user.toJSON())
                    SSTToastView.showSucceed(kMoreUpdateFirstnameOK)
                }
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    fileprivate func modifyAlternativeEmailEvent() {
        SSTProgressHUD.show(view: self.view)
        biz.updateAlternativeEmail(validString(alternativeEmail.text)) { (data, error) in
            SSTProgressHUD.dismiss(view: self.view)
            if data != nil {
                if let user: SSTUser = SSTUser(JSON: validDictionary(data)) {
                    user.type = true
                    biz.user = user
                    FileOP.archive(kUserFileName, object: user.toJSON())
                    SSTToastView.showSucceed(kMoreUpdateAlternativeEmailOK)
                }
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    @IBAction func clickedDobutEvent(_ sender: Any) {
        let errorMessageView = loadNib("\(SSTDoubtMessage.classForCoder())") as! SSTDoubtMessage
        errorMessageView.frame = UIScreen.main.bounds
        let arrorX = askButton.absoluteX + 2
        let aroorY = askButton.absoluteY + kScreenNavigationHeight + 25
        errorMessageView.setFrame(arrorX: arrorX, arrorY: aroorY, messageLeading: 30, messageTrailing: 30, messageStr: kAlternativeEmailInfomation)
        getTopWindow()?.addSubview(errorMessageView)
    }
    
    // MARK: -- UITableViewDataSource, UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            self.performSegue(withIdentifier: SegueIdentifier.toChangePassword.rawValue, sender: self)
        }
    }

}

extension SSTInformationSafetyVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.name {
            let toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
            if toBeString.count > 50 {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == name {
            if validString(textField.text).trim() == validString(biz.user.firstName).trim() {
                textField.resignFirstResponder()
                return true
            }
            guard validInt(textField.text?.count) > 0 else {
                SSTToastView.showError(kMoreInvalidFirstnameTip)
                textField.resignFirstResponder()
                return true
            }
            modifyFirstNameEvent()
        } else if textField == alternativeEmail {
            if validString(textField.text).trim() == validString(biz.user.alternativeEmail).trim() {
                textField.resignFirstResponder()
                return true
            }
            let altEmail = validString(textField.text)
            if altEmail.isNotEmpty && !altEmail.isValidEmail {
                SSTToastView.showError(kMoreInvalidEmailTip)
                textField.resignFirstResponder()
                return true
            }
            modifyAlternativeEmailEvent()
        }
        
        textField.resignFirstResponder()
        return true
    }
}
