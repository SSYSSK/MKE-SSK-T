//
//  SSTMoreProfileCell.swift
//  sst-ios
//
//  Created by Amy on 2017/3/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTMoreProfileCell: SSTBaseCell {

    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var moreClickedView: UIView!
    @IBOutlet weak var profileHeight: NSLayoutConstraint!
    
    var applyInfo = SSTApplyCod()
    
//    var shouldShowTaxView:Bool = false
    var profileImgArr = [String]()
    var profileTitleArr = [String]()
    var arrowDirationIsDown = false

    var clickedProfileBlock:((_ title: String) ->Void)?
    var clickedMoreBtnBlock:((_ shouldShowTax: Bool) ->Void)?
    
    let kItemViewWidth: CGFloat = kScreenWidth / 4
    let kItemViewImageViewWidth: CGFloat = kScreenWidth / 4 / 2
    
    @IBAction func clickedMoreAction(_ sender: AnyObject) {
        arrowDirationIsDown = !arrowDirationIsDown
        clickedMoreBtnBlock?(arrowDirationIsDown)   // arrowDirationIsDown:表示需要展开
        setArrawImage(isDown: arrowDirationIsDown)
    }
    
    func setArrawImage(isDown: Bool? = false) {
        if isDown != nil {
            arrowDirationIsDown = validBool(isDown)
        }
        if arrowDirationIsDown {
            arrowImg.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
            profileHeight.constant = 270 * kProkScreenHeight
        } else {
            arrowImg.transform = CGAffineTransform.identity
            profileHeight.constant = 180 * kProkScreenHeight
        }
    }
    
    func setData(shouldShowTaxView: Bool) {
        if shouldShowTaxView == true {
            moreClickedView.isHidden = false
            profileImgArr = ["icon_more_address", "icon_more_wallet", "icon_more_tax", "icon_more_favorite", "icon_more_payment","icon_more_recently","more_faq",
                             "more_return_policy","more_privacy_policy","more_term_of_service"
                ]
            profileTitleArr = ["Address", "Wallet", "Tax Exemption", "Favorite", "Payment & Delivery","Recently Viewed","F.A.Q","Return Policy","Privacy Policy","Terms of Service"]
        } else {
            moreClickedView.isHidden = false
            profileImgArr = ["icon_more_address","icon_more_wallet","icon_more_favorite","icon_more_payment","icon_more_recently","more_faq",
                             "more_return_policy","more_privacy_policy","more_term_of_service"
                ]
            profileTitleArr = ["Address","Wallet","Favorite","Payment & Delivery","Recently Viewed","F.A.Q","Return Policy","Privacy Policy","Terms of Service"]
        }
        self.buildingView(imageArr: profileImgArr, titleArr: profileTitleArr)
    }
    
    private func buildingView(imageArr: [String], titleArr: [String]) {
        
        // 移除所有子视图
        _ = profileView.subviews.map {
            $0.removeFromSuperview()
        }
        
        
        for ind in 0..<imageArr.count {
            let row = ind / 4
            let col = ind % 4
            
            let outerView = UIView.init(frame: CGRect(x: kItemViewWidth * CGFloat(col), y: CGFloat(row) * kItemViewWidth, width: kItemViewWidth, height: kItemViewWidth))
            
            //image
            let imageView = UIImageView(frame: CGRect(x: (kItemViewWidth - kItemViewImageViewWidth) / 2, y: 5, width: kItemViewImageViewWidth, height: kItemViewImageViewWidth))
            imageView.image = UIImage(named: "\(imageArr[ind])")
            
            //title
            let titleLabel = UILabel(frame: CGRect(x: 5, y: kItemViewWidth - 40, width: outerView.width - 10, height: 30))
            titleLabel.numberOfLines = 2
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.systemFont(ofSize: 12)
            titleLabel.textColor = kDarkGaryColor
            titleLabel.text = validString(titleArr.validObjectAtIndex(ind))
            
            //clickedButton
            let button = UIButton.init(frame: CGRect(x: 0, y: 0, width: kItemViewWidth, height: kItemViewWidth))
            button.tag = ind
            button.addTarget(self, action: #selector(SSTMoreProfileCell.clickedProfile(_:)), for: UIControlEvents.touchUpInside)
            
            outerView.addSubview(button)
            outerView.addSubview(titleLabel)
            outerView.addSubview(imageView)
            
            if (titleLabel.text == "C.O.D." && validInt(applyInfo.codHasNew)  == 1) || (titleLabel.text == "Tax Exemption" && validInt(applyInfo.taxFreeHasNew) == 1) {
                let reddot = UIView.init(frame: CGRect(x: outerView.width - 37 * kProkScreenWidth, y: 14 * kProkScreenWidth, width: 8 * kProkScreenWidth, height: 8 * kProkScreenWidth))
                reddot.layer.cornerRadius = reddot.width / 2
                reddot.backgroundColor = UIColor.red
                reddot.alpha = 0.8
                outerView.addSubview(reddot)
            }
            profileView.addSubview(outerView)
        }
    }
    
    @objc func clickedProfile(_ sender: AnyObject) {
        let button = sender as! UIButton
        let tag = button.tag
        if let block = clickedProfileBlock {
            block(profileTitleArr[tag])
        }
    }
}
