//
//  SSTSearchReslutVC.swift
//  sst-ios
//
//  Created by Amy on 16/5/31.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import PullToRefreshKit

let kFilterViewWidth = kScreenWidth * 0.85

let kSearchResultTitleViewWidth = kScreenWidth - 110

class SSTSearchResultVC: SSTBaseItemsVC, UISearchBarDelegate {
    
    var category: SSTCategory?
    var parentCategory: SSTCategory?
    var device: SSTDevices?
    var parentDeviceName: String?
    
    @IBOutlet weak var filterViewButton: UIView!
    @IBOutlet weak var numFoundLabel: UILabel!
    @IBOutlet weak var styleImageView: UIImageView!
    @IBOutlet weak var priceUpImgV: UIImageView!
    @IBOutlet weak var priceDownImgV: UIImageView!
    @IBOutlet weak var filterDownImgV: UIImageView!
    @IBOutlet weak var titleView: UIView!
    
    var filterView: SSTFilterView!
    
    enum PriceSort: String {
        case asc = "ASC"
        case desc = "DESC"
    }
    var priceSort: PriceSort?
    
    let searchVBg = loadNib("SSTHomeMessageViewBg") as! UIView
    let iconImage = UIImageView()
    
    fileprivate var searchQ: String {
        get {
            return validString(searchKey)
        }
    }
    
    fileprivate var searchGroupIdQ: String {
        get {
            if let tCategory = category {
                return SSTCategory.getLeafIdsForSearch(tCategory).joined(separator: " ")
            }
            return ""
        }
    }
    
    fileprivate var searchSort: String {
        get {
            if priceSort != nil {
                return "\(kItemPrice) \(validString(priceSort?.rawValue))"
            } else if validString(self.device?.deviceId).trim().isNotEmpty {
                return "\(kItemName) ASC"
            }
            return ""
        }
    }
    
    var filterExcludeSoldOut = false
    var fileterPriceRange = ""
    var filterCategoryNames = [String]()
    var filterColorNames = [String]()
    var filterCarriersNames = [String]()
    
    var kFilterViewY: CGFloat {
        return kScreenNavigationHeight + 48
    }
    
    func searchItems(start: Int = 0, facet: String = "") {
        if self.searchQ.isEmpty && self.searchGroupIdQ.isEmpty && validString(self.device?.deviceId).isEmpty {
            printDebug("not valid search.")
            return
        }
        self.itemData.searchItems(self.searchQ, groupId: self.searchGroupIdQ, groupTitle: self.filterCategoryNames, deviceId: validString(self.device?.deviceId), price: fileterPriceRange, excludeSoldOut: filterExcludeSoldOut, start: start, sort: searchSort, facet: facet, color:self.filterColorNames, carrierName:self.filterCarriersNames)
    }
    
    fileprivate var isFilterValid: Bool {
        get {
            if validBool(self.filterExcludeSoldOut) == false && self.fileterPriceRange.isEmpty && validArray(self.filterCategoryNames).count == 0 && validArray(self.filterColorNames).count == 0 && validArray(self.filterCarriersNames).count == 0 {
                return false
            }
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight + 48 + 1, width: kScreenWidth, height: kScreenViewHeight - 48)
        
        SSTProgressHUD.show(view: self.view)
        self.searchItems(facet:"1")

        filterView = loadNib("\(SSTFilterView.classForCoder())") as! SSTFilterView
        
        filterView.filterViewClick = { excludeSoldOut, priceRange,  categoryNames,  colorNames,  carriersNames in
            self.scrollViewContentOffset = CGPoint.zero
            self.hideFilterView()
            
            self.filterExcludeSoldOut = validBool(excludeSoldOut)
            self.fileterPriceRange = validString(priceRange)
            self.filterCategoryNames = validArray(categoryNames) as! [String]
            self.filterColorNames = validArray(colorNames) as! [String]
            self.filterCarriersNames = validArray(carriersNames) as! [String]
            
            if self.isFilterValid {
                self.filterDownImgV.isHighlighted = true
            } else {
                self.filterDownImgV.isHighlighted = false
            }
            
            SSTProgressHUD.show(view: self.view)
            self.searchItems()
        }
        
        styleImageView?.image = UIImage(named: kStyleListImageName)
        
        self.titleView.frame = CGRect(x: 0, y: 0, width: kSearchResultTitleViewWidth, height: 30)
        self.titleView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setTitle()
    }
    
    func setTitle() {
        for subV in self.titleView.subviews {
            subV.removeFromSuperview()
        }
        
        var title = ""
        if self.searchQ.isNotEmpty {
            title = self.searchQ
        } else if category != nil {
            if parentCategory == nil {
                title = clearName("\(validString(category?.name))")
            } else {
                title = clearName("\(validString(parentCategory?.name)) > \(validString(category?.name))")
            }
        } else if device != nil {
            if parentDeviceName?.isEmpty == true {
                title = clearName("\(validString(device?.deviceName))")
            } else {
                title = clearName("\(validString(parentDeviceName)) > \(validString(device?.deviceName))")
            }
        } else {
            title = "Search Result"
        }
        
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
            titleLabel.text = title2
            
            TaskUtil.delayExecuting(1, block: {
                UIView.beginAnimations("SearchResultTitle", context: nil)
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
    
    override func fetchItems(start: Int? = 0) {
        self.searchItems(start: validInt(start))
    }
    
    override func setStyleImage() {
        if layoutStyle == .grid {
            styleImageView.image = UIImage(named: kStyleListImageName)
        } else {
            styleImageView.image = UIImage(named: kStyleGridImageName)
        }
    }
    
    @IBAction func clickedStyleButton(_ sender: AnyObject) {
        self.updateItemViewStyle()
    }
    
    func resetPriceButton() {
        priceSort = nil
        priceUpImgV.isHighlighted = false
        priceDownImgV.isHighlighted = false
    }
    
    @IBAction func clickedPriceButton(_ sender: AnyObject) {
        if priceSort == nil || priceSort == .desc {
            priceSort = PriceSort.asc
            priceUpImgV.isHighlighted = true
            priceDownImgV.isHighlighted = false
        } else {
            priceSort = PriceSort.desc
            priceUpImgV.isHighlighted = false
            priceDownImgV.isHighlighted = true
        }
        scrollViewContentOffset = CGPoint.zero
        SSTProgressHUD.show(view: self.view)
        self.searchItems()
    }
    
    @IBAction func filterEvent(_ sender: AnyObject) {
        iconImage.image = UIImage(named: kArrowUpImgName)
        if filterView.superview != nil {
            self.hideFilterView()
        } else {
            self.showFilterView()
        }
    }
    
    func hideFilterView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.iconImage.alpha = 0.1
//            self.filterView.frame =  CGRect(x: 100, y:  self.filterViewButton.frame.maxY + 80, width: kScreenWidth - 100, height: 0)
            self.filterView.alpha = 0.1
        }, completion: { (data) in
            self.iconImage.removeFromSuperview()
            self.searchVBg.removeFromSuperview()
            self.filterView.removeFromSuperview()
        })
    }
    
    func showFilterView() {
        self.view.addSubview(searchVBg)
        self.view.addSubview(filterView)
        self.view.addSubview(iconImage)
 
        iconImage.frame = CGRect(x: self.filterViewButton.frame.origin.x + self.filterViewButton.frame.size.width / 2, y: kFilterViewY - 10, width: 14, height: 10)
        searchVBg.frame = CGRect(x: 0, y: self.filterViewButton.frame.maxY, width: kScreenWidth, height: kScreenHeight)
        filterView.frame = CGRect(x: kScreenWidth - kFilterViewWidth, y: kFilterViewY, width: kFilterViewWidth, height: 0)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.searchVBg.frame =  CGRect(x: 0, y: self.filterViewButton.frame.maxY, width: kScreenWidth, height: kScreenHeight)
            self.filterView.frame =  CGRect(x: kScreenWidth - kFilterViewWidth, y: self.kFilterViewY, width: kFilterViewWidth, height: kScreenViewHeight - 49)
            self.iconImage.alpha = 1
            self.filterView.alpha = 1
        })
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(filterEvent))
        searchVBg.addGestureRecognizer(tapRecognizer)
    }

    // MARK: -- SSTUIRefreshDelegate

    override func refreshUI(_ data: Any?) {
        super.refreshUI(data)
        
        filterView.categoryFacets = itemData.categoryFacets
        filterView.colorsFacets = itemData.colorsFacets
        filterView.carriersFacets = itemData.carriersFacets
        filterView.type = .categorys
        filterView.facets = filterView.groupedCategoryFacets
        
        if (data as? SSTItemData) == nil {
            numFoundLabel.text = String(format: "%d item%@", 0, "")
            emptyView.buttonClick = { [weak self] in
                SSTProgressHUD.show(view: self?.view)
                self?.searchItems(facet:"1")
            }
        } else {
            numFoundLabel.text = String(format: "%d item%@", itemData.numFound, itemData.items.count > 1 ? "s" : "")
            if self.isFilterValid {
                emptyView.tryAgainButton.isHidden = true
            } else {
                emptyView.tryAgainButton.isHidden = false
                emptyView.buttonClick = { [weak self] in
                    self?.clickedSearchBarButton(nil)
                }
            }
        }
    }
}
