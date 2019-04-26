//
//  SSTDiscountDetailVC.swift
//  sst-ios
//
//  Created by Amy on 2016/11/3.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTDiscountDetailVC: SSTBaseVC {

    @IBOutlet weak var myTableView: UITableView!
    
    fileprivate var discountInformation = SSTDiscountInformation()
    
    fileprivate let kSectionTitleOrderDiscount = "Order Discount"
    fileprivate let kSectionTitleCategoryDiscount = "Category Discount"
    fileprivate let kSectionTitleShipppingDiscount = "Shipping Discount"
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myTableView.rowHeight = UITableViewAutomaticDimension
        myTableView.estimatedRowHeight = 44
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        discountInformation.delegate = self
        
        SSTProgressHUD.show(view: self.view)
        discountInformation.fetchData()
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight)
        emptyView.setData(imgName: kIcon_badConnected, msg: kNoDataTip, buttonTitle: kButtonTitleTryAgain, buttonVisible: true)
        emptyView.buttonClick = {
            SSTProgressHUD.show(view: self.view)
            self.discountInformation.fetchData()
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
    }
    
    @objc func resetViewAfterCancelWhenLoginByAntherAccount() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        discountInformation.orderTips?.removeAll()
        discountInformation.categoryTips?.removeAll()
        discountInformation.freeShippingInfos?.removeAll()
        myTableView.reloadData()
        SSTProgressHUD.show(view: self.view)
        discountInformation.fetchData()
    }
    
    var sections: [String] {
        get {
            var rSections = [String]()
            if validInt(discountInformation.orderTips?.count) > 0 {
                rSections.append(kSectionTitleOrderDiscount)
            }
            if validInt(discountInformation.categoryTips?.count) > 0 {
                rSections.append(kSectionTitleCategoryDiscount)
            }
            if validInt(discountInformation.freeShippingInfos?.count) > 0 {
                rSections.append(kSectionTitleShipppingDiscount)
            }
            return rSections
        }
    }
}

extension SSTDiscountDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == kSectionTitleOrderDiscount {
            return validInt(discountInformation.orderTips?.count)
        } else if sections[section] == kSectionTitleCategoryDiscount {
            return validInt(discountInformation.categoryTips?.count)
        } else if sections[section] == kSectionTitleShipppingDiscount {
            return validInt(discountInformation.freeShippingInfos?.count)
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let titleLabel: UILabel = UILabel(frame: CGRect(x:10, y:0, width:kScreenWidth, height: 15))
        titleLabel.text = "  \(sections[section])"
        titleLabel.textColor = UIColor.gray
        titleLabel.backgroundColor = UIColor.groupTableViewBackground
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        return titleLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sections[indexPath.section] == kSectionTitleOrderDiscount || sections[indexPath.section] == kSectionTitleCategoryDiscount {
            if let cell = tableView.dequeueCell(SSTDiscountDetailCell.self) {
                if sections[indexPath.section] == kSectionTitleCategoryDiscount {
                    if let discount = discountInformation.categoryTips?.validObjectAtIndex(indexPath.row) as? SSTCategoryDiscount {
                        (cell.viewWithTag(1001) as? UIImageView)?.image = UIImage(named: "icon_discount_category")
                        cell.content.attributedText = discount.tip?.toAttributedString()
                    }
                } else {
                    (cell.viewWithTag(1001) as? UIImageView)?.image = UIImage(named: "icon_discount_order")
                    cell.content.attributedText = validString(discountInformation.orderTips?.validObjectAtIndex(indexPath.row)).toAttributedString()
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueCell(SSTDiscountFreeShippingCell.self) {
                if let info = discountInformation.freeShippingInfos?.validObjectAtIndex(indexPath.row) as? SSTFreeShippingInfo {
                    (cell.viewWithTag(1001) as? UIImageView)?.setImage(fileUrl: validString(info.logo))
                    cell.info = info
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension SSTDiscountDetailVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        myTableView.reloadData()
        emptyView.isHidden = discountInformation.isEmpty ? false : true
    }
}
