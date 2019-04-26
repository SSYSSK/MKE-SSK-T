//
//  SSTSolutionListTVC.swift
//  sst-ios
//
//  Created by Amy on 2016/11/3.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTSolutionListTVC: SSTBaseTVC {

    fileprivate var feedbackData = SSTFeedbackData()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44

        SSTProgressHUD.show(view: self.view)
        feedbackData.delegate = self
        feedbackData.fetchData(0)
    }
}

extension SSTSolutionListTVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackData.contents.count
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueCell(SSTSolutionCell.self)
        if cell == nil {
            cell = loadNib("\(SSTSolutionCell.classForCoder())") as? SSTSolutionCell
        }
        let info  = feedbackData.contents[indexPath.row]
        cell?.content.text = info.title
        
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedback = feedbackData.contents[indexPath.row]
        performSegue(withIdentifier: SegueIdentifier.SegueToSolutionDetailVC.rawValue, sender: feedback.url)
    }

}

extension SSTSolutionListTVC: SegueHandlerType {
    enum SegueIdentifier: String {
        case SegueToSolutionDetailVC    = "ToSolutionDetailVC"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let urlStr = validString(sender)
        switch segueIdentifierForSegue(segue) {
        case .SegueToSolutionDetailVC:
            let destVC = segue.destination as! SSTSolutionDetailVC
            destVC.url = urlStr
        }
    }
    
}

extension SSTSolutionListTVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        if data != nil {
            feedbackData = data as! SSTFeedbackData
            self.tableView.reloadData()
        }
    }
    
}

