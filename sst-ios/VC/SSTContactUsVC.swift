//
//  SSTContactUsVC.swift
//  sst-ios
//
//  Created by Amy on 2017/6/13.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit
import MessageUI

class SSTContactUsVC: SSTBaseVC, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var sections = ["Email","Application Related Question(s)","Order Related Question(s)","Item Related Question(s)","Tip"]
    var questionImgs = ["", "contact_application_related", "contact_order_related", "contact_item_related",""]
    
    var emailSubject = ""
    
    enum SegueIdentifier: String {
        case toWeb              = "toWeb"
    }
    fileprivate var webTitle = ""
    fileprivate var webUrl = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 30
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
    }

    @objc func sendEmail() {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        
        controller.setSubject(emailSubject)
        controller.setToRecipients([kContactEmail])
//        controller.setMessageBody("Hello", isHTML: false)

        if !MFMailComposeViewController.canSendMail() {
//            SSTToastView.showError(kEmailNotAvaiable)
            return
        } else {
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            SSTToastView.showSucceed(kEmailSent)
        case .cancelled:
            SSTToastView.showSucceed(kEmailCancelled)
        case.saved:
            SSTToastView.showSucceed(kEmailSaved)
        case.failed:
            SSTToastView.showSucceed(kEmailFailed)
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toWeb.rawValue:
            let destVC = segue.destination as! SSTWebVC
            destVC.webTitle = self.webTitle
            destVC.webUrl = self.webUrl
        default:
            break
        }
    }
    
}

extension SSTContactUsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 4 {
            return 20
        }
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 1, 2, 3:
            return 55
        case 4:
            return UITableViewAutomaticDimension
        default:
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 1, 2, 3:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "ButtonCell") {
                (cell.viewWithTag(1001) as? UILabel)?.text = validString(sections.validObjectAtIndex(indexPath.section))
                (cell.viewWithTag(1002) as? UIImageView)?.image = UIImage(named: validString(questionImgs.validObjectAtIndex(indexPath.section)))
                return cell
            }
        case 0:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "EmailCell") {
                (cell.viewWithTag(1001) as? UIButton)?.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
                return cell
            }
        case 4:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "TipCell") {
                return cell
            }
        default:
            break
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1, 2, 3:
            emailSubject = validString(sections.validObjectAtIndex(indexPath.section))
            self.sendEmail()
        default:
            break
        }
    }
}
