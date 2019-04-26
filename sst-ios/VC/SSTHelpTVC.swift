//
//  SSTHelpTVC.swift
//  sst-ios
//
//  Created by Amy on 2016/11/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
let kShowSize = 5

class SSTHelpTVC: SSTBaseTVC {

    var feedbackData = SSTFeedbackData()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        
        feedbackData.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        feedbackData.fetchData(kShowSize)
    }
    
    @objc func showEvent(_ button: UIButton) {
        performSegueWithIdentifier(.SegueToAllSolutionVC, sender:nil)
    }
}

extension SSTHelpTVC {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if feedbackData.contents.count > 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && feedbackData.contents.count > 0 {
            return feedbackData.contents.count
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && feedbackData.contents.count > 0 {
            return 40
        }
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
   
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headView = UIView(frame:CGRect(x: 0, y: 0, width: kScreenWidth - 40, height: 40))
        
        let label = UILabel(frame: CGRect(x: 20, y: 10, width: 130, height: 20))
        label.text = section == 0 && feedbackData.contents.count > 0 ? kMoreHelpTitlePopularSolution : "" // kMoreHelpTitleFeedback
        label.font = UIFont.systemFont(ofSize: 14)
        if section == 0 && feedbackData.contents.count > 0 && feedbackData.total > kShowSize {
            let seeAllBtn = UIButton(frame: CGRect(x: kScreenWidth - 80, y: 10, width: 80, height: 20))
            seeAllBtn.setTitle(kMoreHelpTitleMore, for: UIControlState())
            seeAllBtn.addTarget(self, action: #selector(showEvent), for:.touchUpInside)
            seeAllBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
            seeAllBtn.setTitleColor(UIColor.darkGray, for: UIControlState())
            headView.addSubview(seeAllBtn)
        }
        
        headView.addSubview(label)
        return headView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && feedbackData.contents.count > 0 {
            let cell = loadNib("\(SSTSolutionCell.classForCoder())") as! SSTSolutionCell
            if let info = feedbackData.contents.validObjectAtIndex(indexPath.row) as? SSTFeedback {
                cell.content.text = info.title
            }
            return cell
        } else {
            let cell = tableView.dequeueCell(SSTFeedbackCell.self)
            return cell!
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let feedback = feedbackData.contents.validObjectAtIndex(indexPath.row) as? SSTFeedback {
                performSegueWithIdentifier(.SegueToSolutionDetailVC, sender: feedback.url as AnyObject?)
            }
        }
    }
}

extension SSTHelpTVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToSolutionDetailVC    = "ToSolutionDetailVC"
        case SegueToAllSolutionVC       = "ToSolutionListVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let urlStr = validString(sender)
        switch segueIdentifierForSegue(segue) {
        case .SegueToSolutionDetailVC:
            let destVC = segue.destination as! SSTSolutionDetailVC
            destVC.url = urlStr
        case .SegueToAllSolutionVC:
            _ = segue.destination as! SSTSolutionListTVC
        }
    }
}

extension SSTHelpTVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if data != nil {
            feedbackData = data as! SSTFeedbackData
            self.tableView.reloadData()
        }
    }
    
}

