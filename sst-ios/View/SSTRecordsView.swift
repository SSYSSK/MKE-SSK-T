//
//  SSTRecordsView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/27.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTRecordsView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    var codRecordsData = SSTCodRecordsData()
    
    var tableViewHeight: CGFloat = 0
    
    let SSTRecordsViewCellForMeId = "SSTRecordsViewCellForMe"
    let SSTRecordsViewCellId = "SSTRecordsViewCell"
    
    var dataType : DataType = .cod
    
    @IBOutlet weak var noDataView: UIView!
    
    var recordViewHiddlenEvent: (() -> Void)?
    
    enum DataType {
        case cod
        case tax
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        codRecordsData.delegate = self

        tableView.frame =  CGRect(x: 10, y: 15, width: 0, height: 0)
        
        tableView.register(UINib(nibName: SSTRecordsViewCellForMeId, bundle: nil), forCellReuseIdentifier: SSTRecordsViewCellForMeId)
        tableView.register(UINib(nibName: SSTRecordsViewCellId, bundle: nil), forCellReuseIdentifier: SSTRecordsViewCellId)
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none;
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 10

        let tap = UITapGestureRecognizer(target: self, action: #selector(SSTRecordsView.hiddlenEvent))
        
        self.addGestureRecognizer(tap)
        
    }
    
    func fetchData(_ dataType: DataType){
        self.dataType = dataType
        switch dataType {
        case .cod :
            SSTProgressHUD.show(view: self.viewController()?.view)
            codRecordsData.getApplyCodRecords()
        case .tax :
            SSTProgressHUD.show(view: self.viewController()?.view)
            codRecordsData.getApplyTAXRecords()
        }
    }
    
    @objc func hiddlenEvent(){
        self.recordViewHiddlenEvent?()
    }
    
}


// MARK: -- UITableViewDelegate
extension SSTRecordsView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return codRecordsData.codRecords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let codRecord = self.codRecordsData.codRecords[indexPath.row]
        
        if codRecord.createBy != "" { //null admin add log
            var cell = tableView.dequeueReusableCell(withIdentifier: SSTRecordsViewCellId) as? SSTRecordsViewCell
            if cell == nil {
                cell = loadNib(SSTRecordsViewCellId) as? SSTRecordsViewCell
            }
            cell?.codRecord = codRecord
            return cell!
        }else {
            var cell = tableView.dequeueReusableCell(withIdentifier: SSTRecordsViewCellForMeId) as? SSTRecordsViewCellForMe
            if cell == nil {
                cell = loadNib(SSTRecordsViewCellForMeId) as? SSTRecordsViewCellForMe
            }
            cell?.codRecord = codRecord
            return cell!
        }
    }
 }

// MARK: -- SSTUIRefreshDelegate
extension SSTRecordsView: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.viewController()?.view)
        if data != nil {

            if codRecordsData.codRecords.count <= 0 {
                noDataView.isHidden = false
            }else {
                noDataView.isHidden = true
            }

            tableView.reloadData()
        }
    }
}
