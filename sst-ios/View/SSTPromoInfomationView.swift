//
//  SSTPromoInfomationView.swift
//  sst-ios
//
//  Created by 天星 on 17/3/17.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTPromoInfomationView: UIView, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var itemClicked: ((_ obj: AnyObject) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    var discountInformation: SSTDiscountInformation! {
        didSet {
            tableView.reloadData()
        }
    }

    @IBAction func enterEvent(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    // MARK: -- UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.height / 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let tDiscount = discountInformation.discountsForHomePopView.validObjectAtIndex(indexPath.row) {
            let cell = loadNib("\(SSTPromoInformatonCell.classForCoder())") as! SSTPromoInformatonCell
            var attributedString = ""
            if tDiscount.isKind(of: SSTCategoryDiscount.self), let categoryDiscount = tDiscount as? SSTCategoryDiscount {
                attributedString = validString(categoryDiscount.tip)
            } else {
                attributedString = validString(tDiscount)
            }
            cell.contentLabel.attributedText = SSTDealMessage.toAttributedString(attributedString.escapeHtmlP(), color: "#8F8F8F")
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let tDiscount = discountInformation.discountsForHomePopView.validObjectAtIndex(indexPath.row) {
            itemClicked?(tDiscount)
        }
    }
    
}
