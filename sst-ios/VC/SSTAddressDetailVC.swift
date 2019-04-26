 //
//  SSTAddressDetailVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import AudioToolbox
 
let kUnitedState        = "United States"
let kCanada             = "Canada"
let kDefaultCountryCode = "defaultCountryCode"
let kDefaultCountryName = "defaultCountryName"

class SSTAddressDetailVC: SSTBaseVC {
    
    var addresses: [SSTShippingAddress]?
    var address: SSTShippingAddress!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmBtn: UIButton!

    fileprivate var countryData = SSTCountryData()
    
    let rowHeight = [70,60,60,60,60,60,60,80]
    
    var lastSavedCountryCode = ""
    var lastSavedCountryName = ""
    
    fileprivate var firstNameTF: UITextField?
    fileprivate var lastNameTF: UITextField?
    fileprivate var countryTF: UITextField?
    fileprivate var zipTF: UITextField?
    fileprivate var cityTF: UITextField?
    fileprivate var stateTF: UITextField?
    
    fileprivate var zipStarLabel: UILabel?
    fileprivate var stateStarLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.onDrag;
        
        countryData.delegate = self
        countryData.getCountry() { (data, error ) in
        }
        
        if address != nil {
            self.title = "Edit Address"
        } else {
            self.title = "Add Address"
            address = SSTShippingAddress()
            
            address.countryCode = "US"
            address.countryName = kUnitedState
            
            lastSavedCountryCode = validString(getUserDefautsData(kDefaultCountryCode))
            lastSavedCountryName = validString(getUserDefautsData(kDefaultCountryName))
            if lastSavedCountryCode.isNotEmpty && lastSavedCountryName.isNotEmpty {
                address.countryCode = lastSavedCountryCode
                address.countryName = lastSavedCountryName
            }
        }
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        if let vc = self.navigationController?.childViewControllers.validObjectAtIndex(validInt(self.navigationController?.childViewControllers.count) - 2) as? SSTMyAddressVC {
            vc.resetViewAfterLoginedByAnotherAccount()
        }
        if validString(address.id) != "" {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setZipStarLabel() {
        if address.countryName == kUnitedState || address.countryName == kCanada {
            self.zipStarLabel?.text = "*"
        } else {
            self.zipStarLabel?.text = ""
        }
    }
    
    func setStateStarLabel() {
        if address.countryName == kUnitedState || address.countryName == kCanada {
            self.stateStarLabel?.text = "*"
        } else {
            self.stateStarLabel?.text = ""
        }
    }
    
    @objc func textDidChange(textField: UITextField) {
        if textField.tag == 1 {
            address.addressName = textField.text
        }
        if textField.tag == 2 {
            address.companyName = textField.text
        }
        if textField.tag == 3 {
            address.firstName = textField.text
        }
        if textField.tag == 4 {
            address.lastName = textField.text
        }
        if textField.tag == 5 {
            address.countryName = textField.text
        }
        if textField.tag == 6 {
            var tZip = validString(textField.text).replacingOccurrences(of: " ", with: "")
            if ( validString(address.countryName?.trim()) == kUnitedState && validInt(tZip.count) > 5) {
                SSTToastView.showError(kMoreInvalidZipForUSTip)
                tZip = tZip.sub(start: 0, end: 4)
                self.zipTF?.text = self.zipTF?.text?.sub(start: 0, end: validInt(self.zipTF?.text?.count) - 2)
            } else if( validString(address.countryName?.trim()) == kCanada && validInt(tZip.count) > 6) {
                SSTToastView.showError(kMoreInvalidZipForCanadaTip)
                tZip = tZip.sub(start: 0, end: 5)
                self.zipTF?.text = self.zipTF?.text?.sub(start: 0, end: validInt(self.zipTF?.text?.count) - 2)
            } else {
                address.zip = tZip
            }
        }
        if textField.tag == 7 {
            address.apt = textField.text
        }
        if textField.tag == 8 {
            address.city = textField.text
        }
        if textField.tag == 9 {
            address.state = textField.text
            address.stateCode = textField.text
        }
        if textField.tag == 10 {
            address.phone = textField.text
        }
        if textField.tag == 11 {
            address.phone2 = textField.text
        }
        if textField.tag == 12 {
            address.email = textField.text
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.resignFirstResponder()
    }
    
    // MARK: -- click event
    
    @IBAction func confirmEvent(_ sender: AnyObject) {
        
        guard validString(address.addressName).isNotEmpty else {
            SSTToastView.showError(kMoreInvalidAddressTitleTip)
            return
        }
//        guard validString(address.companyName).isNotEmpty else {
//            SSTToastView.showError(kMoreEmptyComanyNameTip)
//            return
//        }
        guard validString(address.firstName).isNotEmpty else {
            SSTToastView.showError(kMoreEmptyFirstNameTip)
            return
        }
//        guard validString(address.lastName).isNotEmpty else {
//            SSTToastView.showError(kMoreEmptyLastNameTip)
//            return
//        }
        
        guard validString(address.countryName).isNotEmpty else {
            SSTToastView.showError(kMoreEmptyCountryTip)
            return
        }
        
        guard validString(address.apt).isNotEmpty else {
            SSTToastView.showError(kMoreInvalidStreetTip)
            return
        }
        
        guard validString(address.city).isNotEmpty else {
            SSTToastView.showError(kMoreEmtpyCityTip)
            return
        }
        
        guard validString(self.address.stateCode).isNotEmpty else {
            SSTToastView.showError(kMoreEmptyStateTip)
            return
        }
        
//        if ( validString(address.countryName?.trim()) == kUnitedState || validString(address.countryName?.trim()) == kCanada ) && validString(self.address.stateCode).trim().isEmpty {
//            SSTToastView.showError(kMoreEmptyStateTip)
//            return
//        }
        
        let tZip = validString(address.zip)
        if ( validString(address.countryName?.trim()) == kUnitedState || validString(address.countryName?.trim()) == kCanada ) && tZip.isEmpty {
            SSTToastView.showError(kMoreInvalidZipEmptyTip)
            return
        } else if ( validString(address.countryName?.trim()) == kUnitedState && !tZip.isValidZipForUS) {
            SSTToastView.showError(kMoreInvalidZipForUSTip)
            return
        } else if( validString(address.countryName?.trim()) == kCanada && !tZip.isValidZipForCanada) {
            SSTToastView.showError(kMoreInvalidZipForCanadaTip)
            return
        }
        
//        let phone1 = validString(address.phone)
//        guard phone1.isNotEmpty && phone1.isValidInteger else {
//            SSTToastView.showError(kMoreInvalidPhoneNbrTip)
//            return
//        }
//        
//        let phone2 = validString(address.phone2)
//        guard phone2.isEmpty || phone2.isValidInteger else {
//            SSTToastView.showError(kMoreInvalidPhoneNbr2Tip)
//            return
//        }
//        
//        let phone3 = validString(address.phone3)
//        guard phone3.isEmpty || phone3.isValidInteger else {
//            SSTToastView.showError(kMoreInvalidPhoneNbr3Tip)
//            return
//        }
        
//        let tEmail = validString(address.email)
//        guard tEmail.isNotEmpty && tEmail.isValidEmail else {
//            SSTToastView.showError(kMoreInvalidEmailTip)
//            return
//        }
        
        // check name is existed or not
        if let tAddresses = self.addresses {
            for addr in tAddresses {
                if validString(address.addressName).trim() == validString(addr.addressName).trim() && validString(address.id) != validString(addr.id) {
                    SSTToastView.showError(kAddressDuplicatedNameTip)
                    return
                }
            }
        }
        
        SSTProgressHUD.show(view: self.view)
        if address.id != nil {
            SSTAddressData.updateAddress(address) {[weak self] (message) in
                SSTProgressHUD.dismiss(view: self?.view)
                if validInt(message) == 200 {
                    SSTToastView.showSucceed(kAddressSaveOK)
                    if let addressListVC = self?.navigationController?.childViewControllers.validObjectAtLoopIndex(-2) as? SSTMyAddressVC {
                        addressListVC.refreshView()
                        addressListVC.refreshAddressInBaseOrderShippingVC()
                    }
                    self?.perform(#selector(self?.clickedBackBarButton), with: self, afterDelay: 0.1)
                    UserDefaults.standard.setValue(validString(self?.address.countryCode), forKey: kDefaultCountryCode)
                    UserDefaults.standard.setValue(validString(self?.address.countryName), forKey: kDefaultCountryName)
                } else {
                    SSTToastView.showError(validString(message))
                }
            }
        } else {
            SSTAddressData.addAddress(address) {[weak self] (message) in
                SSTProgressHUD.dismiss(view: self?.view)
                if validInt(message) == 200 {
                    SSTToastView.showSucceed(kAddressSaveOK)
                    if let addressListVC = self?.navigationController?.childViewControllers.validObjectAtLoopIndex(-2) as? SSTMyAddressVC {
                        addressListVC.refreshView()
                    }
                    self?.perform(#selector(self?.clickedBackBarButton), with: self, afterDelay: 0.1)
                    UserDefaults.standard.setValue(validString(self?.address.countryCode), forKey: kDefaultCountryCode)
                    UserDefaults.standard.setValue(validString(self?.address.countryName), forKey: kDefaultCountryName)
                } else {
                    SSTToastView.showError(validString(message))
                }
            }
        }
    }
    
    func setStateGoInImgView(_ country: SSTCountry? = nil) {
        var countrySelected: SSTCountry?
        if country == nil {
            for group in countryData.groups {
                for cntry in group.countries {
                    if cntry.code == address.countryCode {
                        countrySelected = cntry
                        break
                    }
                }
            }
        } else {
            countrySelected = country
        }
        
        if let goInImgV = self.stateTF?.superview?.viewWithTag(1099) as? UIImageView {
            if validInt(countrySelected?.states.count) > 0 {
                goInImgV.isHidden = false
            } else {
                goInImgV.isHidden = true
            }
        }
    }
}

 extension SSTAddressDetailVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToChooseCountryVC   = "toChooseCountryVC"
        case SegueToChooseStateVC     = "ToChooseStateVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segueIdentifierForSegue(segue) {
        case.SegueToChooseCountryVC:
            let destVC = segue.destination as! SSTChooseCountryVC
            destVC.countriesInfo = countryData
            if address.countryName?.isNotEmpty != nil {
                destVC.selectedCountry = validString(address.countryName)
            }
            destVC.chooseCountryBlock = { [weak self] country in
                self?.address.countryName = country.name
                self?.address.countryCode = country.code
                self?.countryTF?.text = country.name
                
                var found = false
                for state in country.states {
                    if state.name == validString(self?.address.state) {
                        found = true
                        break
                    }
                }
                if !found {
                    self?.address.state = ""
                    self?.address.stateCode = ""
                    self?.stateTF?.text = ""
                }
                
                if let tf = self?.countryTF {
                    _ = self?.textFieldShouldReturn(tf)
                }
                
                self?.setStateGoInImgView(country)
            }
        case .SegueToChooseStateVC:
            let destVC = segue.destination as! SSTChooseStateVC
            if let firstLetter = self.address.countryName?.sub(start: 0, end: 0) {
                for group in countryData.groups {
                    if group.name == firstLetter {
                        for country in group.countries {
                            if country.name == validString(self.address.countryName).trim() {
                                destVC.stateData = country.states
                                destVC.selectedState = validString(self.address.state)
                                destVC.chooseStateBlock = { [weak self] (tState,code) in
                                    
                                    self?.address.state = tState
                                    self?.address.stateCode = code
                                    
                                    self?.stateTF?.text = code
                                    
                                    if let tf = self?.stateTF {
                                        _ = self?.textFieldShouldReturn(tf)
                                    }
                                }
                                break
                            }
                        }
                        break
                    }
                }
            }
        }
    }
}
 
// MARK:-- tableView delegate
 
extension SSTAddressDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func  tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    func  tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerV = UIView(frame: CGRect(x:0, y:0, width: kScreenWidth, height: 10))
        headerV.backgroundColor = tableView.backgroundColor
        return headerV
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        if let tmpCell = tableView.dequeueReusableCell(withIdentifier: "\(indexPath.row)") {
            cell = tmpCell
        }
        
        if indexPath.row == 0 {
            let addressNameLabel = cell.contentView.viewWithTag(1) as? UITextField
            addressNameLabel?.text = address.addressName
            addressNameLabel?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            addressNameLabel?.delegate = self
        }
        if indexPath.row == 1 {
            let company =  cell.contentView.viewWithTag(2) as? UITextField
            company?.text = address.companyName
            company?.delegate = self
            company?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
        }
        if indexPath.row == 2 {
            let firstName =  cell.contentView.viewWithTag(3) as? UITextField
            firstName?.text = address.firstName
            firstName?.delegate = self
            firstName?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            self.firstNameTF = firstName
            let lastName =  cell.contentView.viewWithTag(4) as? UITextField
            lastName?.text = address.lastName
            lastName?.delegate = self
            lastName?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            self.lastNameTF = lastName
        }
        if indexPath.row == 3 {
            let country =  cell.contentView.viewWithTag(5) as? UITextField
            country?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            country?.delegate = self
        
            if address.countryName != nil {
                country?.text = address.countryName
            } else {
                //如果是新增地址，则使用上一次修改过的国家地址，如果是第一次增加地址，则默认显示美国
                if lastSavedCountryCode.isNotEmpty && lastSavedCountryName.isNotEmpty {
                    country?.text = lastSavedCountryName
                } else {
                    country?.text = kUnitedState
                }
            }
            self.countryTF = country
            
            let zipCode = cell.contentView.viewWithTag(6) as? UITextField
            zipCode?.text = address.zip
            zipCode?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            zipCode?.delegate = self
            self.zipTF = zipCode
            
            self.zipStarLabel = cell.viewWithTag(6001) as? UILabel
            setZipStarLabel()
        }
        if indexPath.row == 4 {
            let street =  cell.contentView.viewWithTag(7) as? UITextField
            street?.text = address.apt
            street?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            street?.delegate = self
        }
        if indexPath.row == 5 {
            let city =  cell.contentView.viewWithTag(8) as? UITextField
            city?.text = address.city
            city?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            city?.delegate = self
            self.cityTF = city
            
            let state = cell.contentView.viewWithTag(9) as? UITextField
            if address.countryName == kUnitedState {
                state?.text = address.stateCode
            } else {
                state?.text = address.state
            }
            state?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            state?.delegate = self
            self.stateTF = state
            self.setStateGoInImgView()
            
//            self.stateStarLabel = cell.viewWithTag(9001) as? UILabel
//            setStateStarLabel()
        }
        if indexPath.row == 6 {
            let phone1 =  cell.contentView.viewWithTag(10) as? UITextField
            phone1?.text = address.phone
            phone1?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            phone1?.delegate = self
            let phone2 =  cell.contentView.viewWithTag(11) as? UITextField
            phone2?.text = address.phone2
            phone2?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            phone2?.delegate = self
//            let phone3 =  cell.contentView.viewWithTag(12) as? UITextField
//            phone3?.text = address.phone3
//            phone3?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
//            phone3?.delegate = self
            
            for tf in [phone1, phone2] {
                let inputV = SSTInputAccessoryView()
                inputV.buttonClick = {
                    if let tTF = tf {
                        _ = self.textFieldShouldReturn(tTF)
                    }
                }
                tf?.inputAccessoryView = inputV
            }
        }
        if indexPath.row == 7 {
            let email =  cell.contentView.viewWithTag(12) as? UITextField
            email?.text = address.email
            email?.addTarget(self, action: #selector(SSTAddressDetailVC.textDidChange), for: UIControlEvents.editingChanged)
            email?.delegate = self
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return CGFloat(rowHeight[indexPath.row])
        return 55.0
    }
 }
 
extension SSTAddressDetailVC: UITextViewDelegate, UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.firstNameTF || textField == self.lastNameTF {
            let toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
            if toBeString.count > 50 {
                return false
            }
        }
        
        return true
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.countryTF {
            setZipStarLabel()
//            setStateStarLabel()
        }
        
        if let tmpV = tableView.viewWithTag(textField.tag + 1) {
            tmpV.becomeFirstResponder()
        } else {
            self.view.endEditing(true)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 5 {
            if countryData.groups.count > 0 {
                self.performSegueWithIdentifier(SSTAddressDetailVC.SegueIdentifier.SegueToChooseCountryVC, sender: nil)
                return false
            } else {
                return true
            }
        } else if textField.tag == 9 && validInt(address.countryName == kUnitedState) > 0 {
            self.performSegueWithIdentifier(SSTAddressDetailVC.SegueIdentifier.SegueToChooseStateVC, sender: nil)
            return false
        } else {
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == countryTF || textField == zipTF {
            if validString(address.countryCode).isNotEmpty && validString(address.zip).isNotEmpty && ( validString(address.city).isEmpty || validString(address.state).isEmpty ) {
                SSTAddressData.getCityAndState(countryCode: validString(address.countryCode), postalCode: validString(address.zip), callback: { [weak self] (data, error) in
                    if error == nil, let dict = data as? Dictionary<String, String> {
                        if validString(self?.address.id).isEmpty {
                            self?.cityTF?.text = dict[kAddressCityName]
                            self?.address.city = dict[kAddressCityName]
                            self?.stateTF?.text = dict[kAddressStateName]
                            self?.address.stateCode = dict[kAddressStateName]
                        }
                    }
                })
            }
        }
    }
 }
 
// MARK: -- refreshUI delegate
 
extension SSTAddressDetailVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
    }
}
