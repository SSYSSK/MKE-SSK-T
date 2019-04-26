//
//  SSTScrollView.swift
//  sst-ios
//
//  Created by Amy on 16/7/12.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTScrollView: UIView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var items: [AnyObject]!
    var itemWidth: CGFloat!
    var itemHeight: CGFloat!
    var placeholderImgName: String!
    var inBundle = false
    
    var itemClick: ((_ item: AnyObject) -> Void)?

    func setParas(_ items: [AnyObject], itemWidth: CGFloat, itemHeight: CGFloat, placeholder: String, inBundle: Bool = false) {
        self.items = items
        self.itemWidth = itemWidth
        self.itemHeight = itemHeight
        self.placeholderImgName = placeholder
        self.inBundle = inBundle
        
        if items.count > 0 {
            initUI()
        } else {
            let imgV = UIImageView(frame: self.frame)
            imgV.image = UIImage(named: placeholderImgName)
            imgV.frame.size = CGSize(width: itemWidth, height: itemHeight)
            self.addSubview(imgV)
        }
        
        if items.count > 1 {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.isScrollEnabled = false
        }
    }
    
    func getItemView(_ ind: Int) -> UIView {
        let imageView = UIImageView(frame: CGRect(x: CGFloat(ind) * itemWidth, y: 0, width: itemWidth, height: itemHeight))
        if inBundle {
            imageView.image = UIImage(named: validString(self.items[ind]))
        } else {
            imageView.setImage(fileUrl: validString(self.items[ind]), placeholder: placeholderImgName)
        }
        return imageView
    }
    
    func initUI() {
        for subV in scrollView.subviews {
            subV.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: CGFloat(items.count) * itemWidth, height: 0)
        
        for ind in 0 ... items.count - 1 {
            let itemV = getItemView(ind)
            let dataInd = (ind + items.count) % items.count
            
            itemV.tag = dataInd
            
            itemV.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action:#selector(clickedView))
            itemV.addGestureRecognizer(tap)
            
            scrollView.addSubview(itemV)
        }
        
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    @objc func clickedView(_ tap: UITapGestureRecognizer) {
        if let tmpItem = items.validObjectAtIndex(validInt(tap.view?.tag)) {
            itemClick?(tmpItem)
        }
    }
}
