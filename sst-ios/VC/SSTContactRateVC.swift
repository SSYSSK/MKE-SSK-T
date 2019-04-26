//
//  SSTContactRateVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 11/15/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTContactRateVC: UIViewController, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var contactRecord: SSTContactRecord?

    @IBOutlet weak var tableView: UITableView!
    
    var textView: UITextView?
    var holderLabel: UILabel?
    
    let faceImgNames = ["contact_face_terrible", "contact_face_soso", "contact_face_good", "contact_face_perfect"]
    
    var imgViewTag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    @objc func tapFaceButton(_ sender: Any) {
        let buttonTag = validInt((sender as? UIButton)?.tag)
        imgViewTag = buttonTag - 1020
        for ind in 1 ... 4 {
            let imgV = self.view.viewWithTag(1000 + ind) as! UIImageView
            imgV.image = UIImage(named: faceImgNames[ind - 1])
            let lblV = self.view.viewWithTag(1010 + ind) as! UILabel
            lblV.textColor = UIColor.darkGray
            if ind % 10 == buttonTag % 10 {
                imgV.image = UIImage(named: "\(faceImgNames[ind - 1])_sel" )
                lblV.textColor = UIColor.hexStringToColor("f6a623")
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let toBeString = validString((textView.text as NSString?)?.replacingCharacters(in: range, with: text))
        if toBeString.trim().isNotEmpty {
            holderLabel?.isHidden = true
        } else {
            holderLabel?.isHidden = false
        }
        return true
    }
    
    @objc func clickedSubmitButton(_ sender: Any) {
        guard imgViewTag > 0 else {
            SSTToastView.showError(kContactRateTip)
            return
        }
        if imgViewTag < 3 && validString(textView?.text).trim().isEmpty {
            SSTToastView.showError(kContactRateNeedFeedbackTip)
            return
        }
        
        SSTProgressHUD.show(view: self.view)
        contactRecord?.addRateAndSuggestion(score: imgViewTag, suggestion: validString(textView?.text).trim()) { data, error in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                if let contactSSTVC = self.navigationController?.childViewControllers.validObjectAtLoopIndex(-3) as? SSTContactSSTVC {
                    contactSSTVC.upPullLoadData()
                    self.navigationController?.popToViewController(contactSSTVC, animated: true)
                }
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    // MARK: -- UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Rate") {
                for ind in 1 ... 4 {
                    let faceButton = cell.viewWithTag(1020 + ind) as! UIButton
                    faceButton.addTarget(self, action: #selector(tapFaceButton(_:)), for: UIControlEvents.touchUpInside)
                }
                return cell
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Suggestion") {
                if let textView = cell.viewWithTag(2001) as? UITextView {
                    textView.setBorder(color: UIColor.lightGray.withAlphaComponent(0.5), width: 1)
                    textView.cornerRadius = 5
                    textView.delegate = self
                    self.textView = textView
                }
                if let placeholderLabel = cell.viewWithTag(2002) as? UILabel {
                    self.holderLabel = placeholderLabel
                }
                return cell
            }
        } else if indexPath.section == 2 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Button") {
                if let btn = cell.viewWithTag(3001) as? UIButton {
                    btn.addTarget(self, action: #selector(clickedSubmitButton(_:)), for: UIControlEvents.touchUpInside)
                }
                return cell
            }
        }
        return UITableViewCell()
    }
}
