//
//  SSTContactDetailVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

let kReplyTextViewHeight: CGFloat = 41

class SSTContactDetailVC: SSTBaseVC, UITextFieldDelegate {
    
    var record: SSTContactRecord!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var replyTV: UITextView!
    
    @IBOutlet weak var replyTextView: UIView!
    @IBOutlet weak var replyFileView: UIView!
    
    @IBOutlet weak var replyTextViewBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var replyFileViewBottomConstant: NSLayoutConstraint!
    @IBOutlet weak var replyTextViewHeightConstant: NSLayoutConstraint!
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var tipForDoneLabel: UILabel!
    
    @IBOutlet weak var doneButtonItem: UIBarButtonItem!
    
    var keyboardHeight: CGFloat = 0
    var textViewFrameTask: AsynTask?
    let kTableViewHeight: CGFloat = kScreenHeight - kScreenNavigationHeight - kReplyTextViewHeight - kScreenBottomSpaceHeight
    
    enum SegueIdentifier: String {
        case toRateVC           = "toRateVC"
    }
    
    fileprivate lazy var pickVC: UIImagePickerController = {
        let pickVC = UIImagePickerController()
        pickVC.delegate = self
        pickVC.allowsEditing = false
        return pickVC
    }()
    
    var groups = [SSTGroup]()
    
    func groupItems() {
        var tGroups = [SSTGroup]()
        
        var group = SSTGroup(name: validDate(record.dateCreated).formatHMmmddyyyy(), itms: [record])
        tGroups.append(group)
        var prevDateCreated = record.dateCreated
        
        for reply in record.replies {
            if validDate(reply.dateCreated).timeIntervalSince(validDate(prevDateCreated)) < 3 * 60 {
                group.items.append(reply)
            } else {
                group = SSTGroup(name: validDate(reply.dateCreated).formatHMmmddyyyy(), itms: [reply])
                tGroups.append(group)
            }
            prevDateCreated = reply.dateCreated
        }
        
        self.groups = tGroups
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.tableView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kTableViewHeight)

        self.title = "Subject: \(validString(record?.title))"
        
        NotificationCenter.default.addObserver(self, selector: #selector(detailhandleKeyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(detailhandleKeyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.replyTV.layer.borderColor = UIColor(red: 199/255, green: 199/255, blue: 199/255, alpha: 1).cgColor
        self.replyTV.layer.borderWidth = 0.5
        self.replyTV.layer.cornerRadius = 7
        
        record.delegate = self
        SSTProgressHUD.show(view: self.view)
        record.fetchContactRecordReplies(id: validString(record.id))
        
        IQKeyboardManager.sharedManager().enable = false
        self.hideKeyboardWhenTappedAround()
        
        self.titleView.frame = CGRect(x: 0, y: 0, width: kSearchResultTitleViewWidth, height: 30)
        self.titleView.clipsToBounds = true
        
        self.hideDoneBarItem()
    }
    
    func hideDoneBarItem() {
        doneButtonItem.title = ""
        doneButtonItem.isEnabled = false
    }
    
    func showDoneBarItem() {
        doneButtonItem.title = "Done"
        doneButtonItem.isEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTitle()
    }
    
    func setTitle() {
        for subV in self.titleView.subviews {
            subV.removeFromSuperview()
        }
        
        let title = "Subject: \(validString(record?.title))"
        
        let titleLabel = UILabel(frame: CGRect(x:0, y:0, width:5000, height:30))
        titleLabel.textColor = kNavigationBarForegroundColor
        titleLabel.font = kNavigationBarFont
        
        if title.sizeByFont(font: kNavigationBarFont).width <= kSearchResultTitleViewWidth {
            titleLabel.frame.size = CGSize(width:kSearchResultTitleViewWidth - 15, height:30)
            titleLabel.textAlignment = .center
            titleLabel.text = title
            titleLabel.adjustsFontSizeToFitWidth = true
        } else {
            titleLabel.textAlignment = .left
            let title1 = "\(title)             "
            let title2 = "\(title1)\(title)"
            let title1Width = title1.sizeByFont(font: kNavigationBarFont).width
            titleLabel.text =  title2
            
            TaskUtil.delayExecuting(1, block: {
                UIView.beginAnimations("ContactDetailTitle", context: nil)
                UIView.setAnimationDuration(16)
                UIView.setAnimationCurve(.linear)
                UIView.setAnimationDelegate(self)
                UIView.setAnimationRepeatCount(999999)
                titleLabel.frame.origin.x = -title1Width
                UIView.commitAnimations()
            })
        }
        
        self.titleView.addSubview(titleLabel)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        IQKeyboardManager.sharedManager().enable = true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapTableView))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
    }
    
    @objc func tapTableView() {
        if keyboardHeight > validCGFloat(kOneInMillion) {
            view.endEditing(true)
            scrollReplyTextViewToBottom()
            hideReplyFileView()
        } else if self.replyFileView.isHidden == false {
            clickedPlusButton(self)
        }
    }
    
    @objc func detailhandleKeyboardWillShow(_ notification: Notification) {
        if keyboardHeight > CGFloat(kOneInMillion) {
            if self.textViewFrameTask != nil {
                TaskUtil.cancel(self.textViewFrameTask)
            }
            self.textViewFrameTask = TaskUtil.delayExecuting(0.05) {
                self.setTextView(notification: notification)
            }
        } else {
            self.setTextView(notification: notification)
        }
    }
    
    func setTextView(notification: Notification) {
        if replyTV.isFirstResponder {
            let userinfo: NSDictionary = notification.userInfo! as NSDictionary
            let nsValue = userinfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRect = nsValue.cgRectValue
            keyboardHeight = keyboardRect.size.height
            
            var duration = 0.3
            if self.replyTextView.y > kScreenHeight - self.replyTextView.height - keyboardHeight / 2 {
                duration = 0.3
            } else {
                duration = 0.01
            }
            
            UIView.animate(withDuration: duration, animations: {
                printDebug(self.keyboardHeight)
                self.replyTextView.frame = CGRect(x: 0, y: kScreenHeight - self.replyTextView.height - self.keyboardHeight, width: kScreenWidth, height: self.replyTextView.height)
                self.replyFileView.frame = CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: self.replyFileView.height)
                let kAvailableContentH = kScreenHeight - kScreenNavigationHeight - self.replyTextView.height - self.keyboardHeight - kScreenBottomSpaceHeight
                if self.tableView.contentSize.height <= kAvailableContentH {
                    self.tableView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kAvailableContentH)
                } else if self.tableView.contentSize.height <= kScreenHeight - kScreenNavigationHeight - self.replyTextView.height {
                    self.tableView.frame = CGRect(x: 0, y: kScreenNavigationHeight + kAvailableContentH - self.tableView.contentSize.height, width: kScreenWidth, height: self.kTableViewHeight)
                } else {
                    self.tableView.frame = CGRect(x: 0, y: kScreenNavigationHeight - self.keyboardHeight, width: kScreenWidth, height: self.kTableViewHeight)
                }
            }, completion: { (Bool) in
                printDebug(self.keyboardHeight)
                self.replyTextViewBottomConstant.constant = -self.keyboardHeight + kScreenBottomSpaceHeight
                self.replyFileViewBottomConstant.constant = 119
            })
            
            self.replyFileView.isHidden = true
        }
    }
    
    @objc func detailhandleKeyboardWillHide(_ notification: Notification) {
        scrollReplyTextViewToBottom()
//        if self.replyFileView.isHidden == false {
//            hideReplyFileView()
//        }
        keyboardHeight = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        clickedSendButton(self)
        return false
    }
    
    @IBAction func clickedSendButton(_ sender: Any) {
        if validString(replyTV.text).trim().isEmpty {
            SSTToastView.showError("Please enter your message first")
            return
        }
        
//        tapTableView()
        
        SSTProgressHUD.show(view: self.view)
        record.addReply(msg: validString(replyTV.text).trim()) { data, error in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                self.replyTV.text = ""
                self.replyTextViewHeightConstant.constant = kReplyTextViewHeight
                self.replyTextView.layoutIfNeeded()
//                self.replyTF.resignFirstResponder()
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    @IBAction func clickedPlusButton(_ sender: Any) {
        TaskUtil.delayExecuting(0.01) {
            if self.replyFileView.isHidden {
                self.replyFileView.isHidden = false
                if self.keyboardHeight > validCGFloat(kOneInMillion) {   // keyboard is showing
                    self.replyTV.resignFirstResponder()
                    UIView.animate(withDuration: 0.05, animations: {
                        self.replyTextView.frame = CGRect(x: 0, y: kScreenHeight - self.replyTextView.height - 119 - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyTextView.height)
                        self.replyFileView.frame = CGRect(x: 0, y: kScreenHeight - self.replyFileView.height - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyFileView.height)
                    }, completion: { b in
                        self.replyTextViewBottomConstant.constant = -119 - kScreenBottomSpaceHeight
                        self.replyFileViewBottomConstant.constant = -kScreenBottomSpaceHeight
                    })
                    TaskUtil.delayExecuting(0.1, block: {
                        self.tableView.frame.origin = CGPoint(x: 0, y: kScreenNavigationHeight - 119)
                    })
                } else {
                    UIView.animate(withDuration: 0.2, animations: {
                        self.replyTextView.frame = CGRect(x: 0, y: kScreenHeight - self.replyTextView.height - 119 - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyTextView.height)
                        self.replyFileView.frame = CGRect(x: 0, y: kScreenHeight - self.replyFileView.height - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyFileView.height)
                        self.tableView.frame.origin = CGPoint(x: 0, y: kScreenNavigationHeight - 119 - kScreenBottomSpaceHeight)
                    }, completion: { (Bool) in
                        self.replyTextViewBottomConstant.constant = -119 - kScreenBottomSpaceHeight
                        self.replyFileViewBottomConstant.constant = -kScreenBottomSpaceHeight
                    })
                }
            } else {
                self.replyTV.resignFirstResponder()
                self.hideReplyFileView()
            }
        }
    }
    
    func scrollReplyTextViewToBottom() {
        UIView.animate(withDuration: 0.33) {
            self.replyTextView.frame = CGRect(x: 0, y: kScreenHeight - self.replyTextView.height - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyTextView.height)
            self.tableView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: self.kTableViewHeight)
            self.replyTextViewBottomConstant.constant = -kScreenBottomSpaceHeight
        }
    }
    
    func hideReplyFileView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.replyTextView.frame = CGRect(x: 0, y: kScreenHeight - self.replyTextView.height - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyTextView.height)
            self.replyFileView.frame = CGRect(x: 0, y: kScreenHeight - kScreenBottomSpaceHeight, width: kScreenWidth, height: self.replyFileView.height)
            self.tableView.frame.origin = CGPoint(x: 0, y: kScreenNavigationHeight)
        }, completion: { (Bool) in
            self.replyTextViewBottomConstant.constant = 0
            self.replyFileViewBottomConstant.constant = 119
            self.replyFileView.isHidden = true
        })
    }
    
    @IBAction func clickedCaptureButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickVC.sourceType = .camera
            self.present(pickVC, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            })
        } else {
            SSTToastView.showError("Unable to open camera!")
        }
    }
    
    @IBAction func clickedGalleryButton(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickVC.sourceType = .photoLibrary
            self.present(pickVC, animated: true, completion: {
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            })
        } else {
            SSTToastView.showError("Unable to open gallery!")
        }
    }
    
    @IBAction func clickedDoneBarItem(_ sender: Any) {
        let mAC = UIAlertController(title: "", message: kContactToDoneTip, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: { action in
            var hasSSTReply = false
            for reply in self.record.replies {
                if !reply.isMyself {
                    hasSSTReply = true
                }
            }
            if hasSSTReply {
                self.performSegue(withIdentifier: SegueIdentifier.toRateVC.rawValue, sender: self)
            } else {
                SSTProgressHUD.show(view: self.view)
                self.record.addRateAndSuggestion(score: 0, suggestion: "") { data, error in
                    SSTProgressHUD.dismiss(view: self.view)
                    if error == nil {
                        if let contactSSTVC = self.navigationController?.childViewControllers.validObjectAtLoopIndex(-2) as? SSTContactSSTVC {
                            contactSSTVC.upPullLoadData()
                            self.navigationController?.popToViewController(contactSSTVC, animated: true)
                        }
                    } else {
                        SSTToastView.showError(validString(error))
                    }
                }
            }
        })
        mAC.addAction(cancelAction)
        mAC.addAction(doneAction)
        self.present(mAC, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination.isKind(of: SSTContactRateVC.classForCoder()) {
            let rateVC = segue.destination as! SSTContactRateVC
            rateVC.contactRecord = self.record
        }
    }
}

extension SSTContactDetailVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let height: CGFloat = replyTV.sizeThatFits(CGSize(width: kScreenWidth - 48 - 48, height: 30)).height
        replyTV.isScrollEnabled = height > 80
        if validDouble(height) > 30.1 && height < 80 {
            replyTextViewHeightConstant.constant = CGFloat(height + 4 + 4)
            replyTextView.layoutIfNeeded()
        }
    }
}

extension SSTContactDetailVC: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        replyTV.resignFirstResponder()
        scrollReplyTextViewToBottom()
        hideReplyFileView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return groups[section].items.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let outerView = UIView(frame: CGRect(x:0, y:0, width: kScreenWidth, height: 30))
        
        let titleLabel = UILabel(frame: CGRect(x: (kScreenWidth - 133) / 2, y: 15, width: 133, height: 21))
        titleLabel.font = UIFont.systemFont(ofSize: 11)
        titleLabel.textAlignment = .center
        titleLabel.text = groups[section].name
        titleLabel.backgroundColor = UIColor.colorWithCustom(178, g: 177, b: 195)
        titleLabel.textColor = UIColor.white
        titleLabel.layer.cornerRadius = 3
        titleLabel.layer.masksToBounds = true
        
        outerView.addSubview(titleLabel)
        return outerView
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = self.tableView(tableView, cellForRowAt: indexPath)
//        return cell.frame.size.height
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let rcd = groups[indexPath.section].items.validObjectAtIndex(indexPath.row) as? SSTContactRecord {
            let cell = loadNib("\(SSTTalkMsgForMeCell.classForCoder())") as! SSTTalkMsgForMeCell
            cell.record = rcd
            return cell
        } else if let rply = groups[indexPath.section].items.validObjectAtIndex(indexPath.row) as? SSTContactReply {
            if rply.isMyself {
                if rply.isMessage {
                    let tCell = loadNib("\(SSTTalkMsgForMeCell.classForCoder())") as! SSTTalkMsgForMeCell
                    return getMsgCell(cell: tCell, reply: rply)
                } else {
                    let tCell = loadNib("\(SSTTalkImageForMeCell.classForCoder())") as! SSTTalkImageForMeCell
                    return getImageCell(cell: tCell, reply: rply)
                }
            } else {
                if rply.isMessage {
                    let tCell = loadNib("\(SSTTalkMsgForOthersCell.classForCoder())") as! SSTTalkMsgForOthersCell
                    return getMsgCell(cell: tCell, reply: rply)
                } else {
                    let tCell = loadNib("\(SSTTalkImageForOthersCell.classForCoder())") as! SSTTalkImageForOthersCell
                    return getImageCell(cell: tCell, reply: rply)
                }
            }
        }
        
        return UITableViewCell()
    }
    
    func getMsgCell(cell: SSTTalkMsgCell, reply: SSTContactReply) -> SSTTalkMsgCell {
        cell.reply = reply
        return cell
    }
    
    func getImageCell(cell: SSTTalkImageCell, reply: SSTContactReply) -> SSTTalkImageCell {
        cell.reply = reply
        cell.imageClick = { imgUrl in
            let vc = SSTImageViewVC()
            vc.indexPath = IndexPath(row: 0, section: 0)
            vc.imgUrls = [imgUrl]
            vc.modalPresentationStyle = .custom
            self.present(vc, animated: false, completion: nil)
        }
        return cell
    }
}

// MARK: -- imagePicker delegate

extension SSTContactDetailVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let typeStr = info[UIImagePickerControllerMediaType] as? String {
            if typeStr == "public.image" {
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                SSTProgressHUD.show(view: self.view)
                record.addReplyImage(image: image, fileName: "name") { data, error in
                    SSTProgressHUD.dismiss(view: self.view)
                    if error == nil {
                        self.hideReplyFileView()
                    } else {
                        SSTToastView.showError(validString(error))
                    }
                }
            }
        } else {
            SSTToastView.showError(kOpenPhotoFailedText)
        }
        picker.dismiss(animated: true, completion: {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        })
    }
}

// MARK: -- SSTUIRefreshDelegate

extension SSTContactDetailVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        groupItems()
        tableView.reloadData()
        
        TaskUtil.delayExecuting(0.1) {
            self.tableView.scrollToRow(at: IndexPath(row: self.tableView.numberOfRows(inSection: self.tableView.numberOfSections - 1) - 1, section: self.tableView.numberOfSections - 1), at: .bottom, animated: false)
        }
        
        if record.statusText == "Done" {
            self.hideDoneBarItem()
            tipForDoneLabel.isHidden = false
        } else {
            self.showDoneBarItem()
            tipForDoneLabel.isHidden = true
        }
        
        if let prevVC = self.navigationController?.childViewControllers.validObjectAtLoopIndex(-2) as? SSTContactSSTVC {
            prevVC.recordClicked?.msgCnt = 0
            prevVC.tableView.reloadData()
        }
    }
}
