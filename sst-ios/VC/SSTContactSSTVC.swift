//
//  SSTContactSSTVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTContactSSTVC: SSTBaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomViewBottomConstant: NSLayoutConstraint!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    let contactData = SSTContactData()
    
    enum SegueIdentifier: String {
        case toContactDetail    = "toContactDetail"
        case toContactAdd       = "toContactAdd"
    }
    var recordClicked: SSTContactRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = tableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.upPullLoadData()
        }
        
        if kIsIphoneX {
            bottomViewBottomConstant.constant = -24
        } else {
            bottomViewBottomConstant.constant = 0
        }
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight)
        emptyView.setData(imgName: kNoContactsImgName, msg: kNoContactsTip, buttonTitle: "", buttonVisible: false)
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        
        contactData.delegate = self
        self.upPullLoadData()
    }
    
    // MARK: -- XWSwiftRefresh
    
    func upPullLoadData() {
        SSTProgressHUD.show(view: self.view)
        contactData.fetchData()
    }

    @IBAction func clickedNewSupportTicketButton(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentifier.toContactAdd.rawValue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.toContactDetail.rawValue:
            let destVC = segue.destination as! SSTContactDetailVC
            destVC.record = recordClicked
        default:
            break
        }
    }
}

extension SSTContactSSTVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return contactData.records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTContactSSTCell.classForCoder())", for: indexPath) as! SSTContactSSTCell
        cell.record = contactData.records.validObjectAtLoopIndex(indexPath.row) as? SSTContactRecord
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.recordClicked = contactData.records.validObjectAtIndex(indexPath.row) as? SSTContactRecord
        performSegue(withIdentifier: SegueIdentifier.toContactDetail.rawValue, sender: self)
    }
}

// MARK: -- SSTUIRefreshDelegate

extension SSTContactSSTVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        
        if (data as? SSTContactData) == nil {
            tableView.endHeaderRefreshing(.failure, delay: 0.5)
        } else {
            tableView.endHeaderRefreshing(.success, delay: 0.5)
            tableView.reloadData()
        }
        
        emptyView.isHidden = contactData.records.count > 0
    }
}
