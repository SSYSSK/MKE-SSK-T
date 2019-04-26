//
//  SSTHomeMessageView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/10/17.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import PullToRefreshKit

let kHomeMessageViewTBCellHeight: CGFloat = 90

class SSTHomeMessageView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var outerTBView: UIView!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    var messageData = SSTMessageData()
    var asynTask: AsynTask?
    
    var itemClicked: ((_ item: SSTMessage?) -> Void)?
    
    var tableViewHeight: CGFloat {
        get {
            let maxCellCnt = validInt((kScreenHeight - kScreenNavigationHeight - kScreenTabbarHeight) * 0.75 / kHomeMessageViewTBCellHeight)
            return CGFloat(max(3, min(maxCellCnt, messageData.messages.count))) * kHomeMessageViewTBCellHeight
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        messageData.delegate = self
        
        tableView.register(UINib(nibName: "\(SSTHomeMessageCell.classForCoder())", bundle: nil), forCellReuseIdentifier: "\(SSTHomeMessageCell.classForCoder())")
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        self.outerTBView.frame = CGRect(x: 10, y: 10, width: kScreenWidth - 20, height: self.tableViewHeight)
        SSTProgressHUD.show(view: self.outerTBView)
        self.upPullLoadData()

        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height:70))
        _ = self.tableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
             self?.upPullLoadData()
        }
        
        _ = self.tableView.setUpFooterRefresh { [weak self] in
            self?.downPullLoadData()
            }.SetUp { (footer) in
                setRefreshFooter(footer)
        }
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(clickedBgView))
        self.bgView.addGestureRecognizer(tapRecognizer)
        
        emptyView.frame = CGRect(x: 10, y: 12, width: kScreenWidth - 20, height: kScreenHeight/2)
        emptyView.setData(imgName: kIcon_badConnected, msg: kNoHomeMessageTip, buttonTitle: kButtonTitleRefresh, buttonVisible: true)
        emptyView.buttonClick = {
            SSTProgressHUD.show(view: self.emptyView)
            self.messageData.fetchData()
        }
        emptyView.isHidden = true
        emptyView.layer.cornerRadius = 3
        self.addSubview(emptyView)
    }
    
    func show() {
        UIView.animate(withDuration: 0.2, animations: {
            self.outerTBView.frame = CGRect(x: 10, y: 10, width: kScreenWidth - 20, height: self.tableViewHeight)
            self.tableView.frame = CGRect(x: 0, y: 0, width: kScreenWidth - 20, height: self.tableViewHeight + 44)
            self.alpha = 1
        })
    }
    
    @objc func clickedBgView(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.2, animations: {
            self.outerTBView.frame = CGRect(x: 10, y: 10, width: kScreenWidth - 20, height: 0)
            self.alpha = 0.1
        }, completion: { (data) in
            self.removeFromSuperview()
        })
    }
    
    func upPullLoadData() {
        messageData.fetchData()
    }
    
    func downPullLoadData() {
        if messageData.messages.count < messageData.numFound {
//            SSTProgressHUD.show(view: self.outerTBView)
            messageData.fetchData(start: messageData.messages.count)
        } else {
            tableView.endFooterRefreshingWithNoMoreData()
        }
    }
}

// MARK: -- UITableViewDelegate, UITableViewDataSource

extension SSTHomeMessageView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageData.messages.count
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return kHomeMessageViewTBCellHeight
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTHomeMessageCell.classForCoder())") as! SSTHomeMessageCell
        if let msg = messageData.messages.validObjectAtIndex(indexPath.row) as? SSTMessage {
            cell.message = msg
        }
        cell.lineView.isHidden = indexPath.row == messageData.messages.count - 1 ? true : false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let message = messageData.messages.validObjectAtIndex(indexPath.row) as? SSTMessage {
            self.itemClicked?(message)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
}

// MARK: -- SSTUIRefreshDelegate

extension SSTHomeMessageView: SSTUIRefreshDelegate {
    
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.outerTBView)
        SSTProgressHUD.dismiss(view: self.emptyView)
        
        if data != nil {
            messageData = data as! SSTMessageData
            
            if messageData.messages.count < messageData.numFound {
                tableView.endFooterRefreshing()
            } else {
                tableView.endFooterRefreshingWithNoMoreData()
            }
            tableView.endHeaderRefreshing(.success, delay: 0.5)
            tableView.reloadData()
            
            if messageData.messages.count > 0 {
                self.show()
                self.messageData.saveMessageRecord() { data, error in
                    if error == nil {
                        (gMainTC?.selectedViewController?.childViewControllers.first as? SSTHomeVC)?.refreshMsgBarItem()
                    }
                }
            }
        } else {
            tableView.endHeaderRefreshing(.failure, delay: 0.5)
        }
        
        emptyView.isHidden = messageData.messages.count <= 0 ? false : true
    }
}
