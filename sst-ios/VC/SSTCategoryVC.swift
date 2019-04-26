//
//  SSTCategoryTabVC.swift
//  sst-mobile
//
//  Created by Amy on 16/4/12.
//  Copyright © 2016年 lzhang. All rights reserved.
//

import UIKit

enum CategoryOrBrand {
    case category
    case brand
    case series
    case devices
    case advertis
}

class SSTCategoryVC: SSTBaseSearchVC {
    
    @IBOutlet weak var brandButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var categoryBrandView: SSTCategoryBrandView!
    @IBOutlet weak var tableView: UITableView!
    
    var emptyView = loadNib("\(SSTDataEmptyView.classForCoder())") as! SSTDataEmptyView
    
    fileprivate var headView : SSTCategoryBrandHeadView!
    fileprivate let kHeadViewHeight: CGFloat = 42
    
    fileprivate var categoryData = SSTCategoryData()
    fileprivate var brandData = SSTBrandData()
    
    fileprivate var typeClicked: CategoryOrBrand = .category
    
    fileprivate var categoryClicked: SSTCategory?
    fileprivate var brandClicked: SSTBrand?
    fileprivate var productIdClicked: String?
    
    fileprivate let kTitleAdvertisingProducts = "Advertising Products"
    fileprivate let kTitlePopularBrands = "Popular Brands"
    
    fileprivate var topSectionTitles: [String] {
        get {
            var sectionTitles = [String]()
            sectionTitles.append(kTitleAdvertisingProducts)
            if typeClicked == .brand && brandData.brandsInHot.count > 0 {
                sectionTitles.append(kTitlePopularBrands)
            }
            return sectionTitles
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "\(SSTCategoryViewCell.classForCoder())", bundle:nil), forCellReuseIdentifier: "\(SSTCategoryViewCell.classForCoder())")
        tableView.register(UINib(nibName: "\(SSTCategoryBrandHeadView.classForCoder())", bundle:nil), forCellReuseIdentifier: "\(SSTCategoryBrandHeadView.classForCoder())")
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.addObserver(self, selector:#selector(viewRefreshAfterApplicationDidBecomeActive), name: kApplicationDidBecomeActive, object: nil)
        
        categoryData.delegate = self
        brandData.delegate = self
        biz.hotProductData.delegate = self
        
        fetchData()
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = self.tableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.fetchDataByTypeClicked()
        }
        
        categoryBrandView?.clickedCategoryBrandView = { categoryBrandViewEnum in
            self.typeClicked = categoryBrandViewEnum
            self.fetchDataByTypeClicked()
        }
        
        emptyView.frame = CGRect(x: 0, y: kScreenNavigationHeight + kHeadViewHeight, width: kScreenWidth, height: kScreenViewHeight - kHeadViewHeight)
        emptyView.setData(imgName: kIcon_badConnected, msg: kNoDataTip, buttonTitle: kButtonTitleTryAgain, buttonVisible: true)
        emptyView.buttonClick = {
            self.fetchDataByTypeClicked()
        }
        emptyView.isHidden = true
        self.view.addSubview(emptyView)
        
        self.view.bringSubview(toFront: categoryBrandView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.categoryClicked = nil
        self.brandClicked = nil
        self.searchKey = nil
    }
    
    @objc func viewRefreshAfterApplicationDidBecomeActive() {
        fetchData()
    }
    
    func fetchCategoryData() {
        if validInt(categoryData.category.subs?.count) == 0 {
            SSTProgressHUD.show(view: self.view)
        }
        categoryData.fetchData()
    }
    
    override func fetchData() {
        biz.hotProductData.getAdvertisingProducts()
        fetchCategoryData()
        brandData.getBrands()
    }
    
    func fetchDataByTypeClicked() {
        switch self.typeClicked {
        case CategoryOrBrand.brand:
            self.brandData.getBrands()
        case CategoryOrBrand.category:
            self.fetchCategoryData()
        default:
            break
        }
    }
    
    @IBAction func categoryEvent(_ sender: Any) {
        brandButton.setTitleColor(RGBA(73, g: 73, b: 73, a: 1), for: UIControlState.normal)
        categoryButton.setTitleColor(RGBA(111, g: 116, b: 244, a: 1), for: UIControlState.normal)
        UIView.animate(withDuration: 0.1) {
            self.lineView.center = CGPoint(x: kScreenWidth / 4, y: 41)
        }
        typeClicked = .category
        if validInt(categoryData.category.subs?.count) <= 0 {
            self.fetchDataByTypeClicked()
        } else {
            refreshUI(categoryData)
        }
    }
    
    @IBAction func brandEvent(_ sender: Any) {
        brandButton.setTitleColor(RGBA(111, g: 116, b: 244, a: 1), for: UIControlState.normal)
        categoryButton.setTitleColor(RGBA(73, g: 73, b: 73, a: 1), for: UIControlState.normal)
        UIView.animate(withDuration: 0.1) {
            self.lineView.center = CGPoint(x: kScreenWidth / 4 * 3, y: 41)
        }
        typeClicked = .brand
        if brandData.brands.count <= 0 {
            self.fetchDataByTypeClicked()
        } else {
            refreshUI(brandData)
        }
    }
    
    override func clickedSearchBarButton(_ sender: Any?) {
        self.productIdClicked = nil
        super.clickedSearchBarButton(sender)
    }
}

// MARK: -- UITableViewDelegate, UITableViewDataSource

extension SSTCategoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch typeClicked {
        case .category:
            return topSectionTitles.count + 1
        case .brand:
            return topSectionTitles.count + brandData.brandGroups.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if validString(topSectionTitles.validObjectAtIndex(section)) == kTitleAdvertisingProducts {
            return 1
        } else if validString(topSectionTitles.validObjectAtIndex(section)) == kTitlePopularBrands {
            return brandData.brandsInHot.count
        } else {
            switch typeClicked {
            case .category:
                return validInt(categoryData.category.subs?.count)
            case .brand:
                return validInt((brandData.brandGroups.validObjectAtIndex(section - topSectionTitles.count) as? [SSTBrand])?.count)
            default :
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if validString(topSectionTitles.validObjectAtIndex(section)) == kTitleAdvertisingProducts {
            let slideCell = loadNib("\(SSTCategoryBrandHeadView.classForCoder())") as! SSTCategoryBrandHeadView
            slideCell.setParas(biz.hotProductData.advertisingProducts, itemWidth: kScreenWidth, itemHeight: kHomeSlideHeight, placeholder: kIcon_slide)
            slideCell.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kHomeSlideHeight)
            slideCell.itemClick = { item in
                if let tmpHotProduct = item as? SSTHotProduct {
                    self.productIdClicked = tmpHotProduct.productId
                    self.performSegueWithIdentifier(SegueIdentifier.toItemDetails, sender: nil)
                }
            }
            return slideCell
        }
        
        switch typeClicked {
        case .category:
            return UIView()
        case .brand:
            if validString(topSectionTitles.validObjectAtIndex(section)) == kTitlePopularBrands {
                let popularSectionHeadView = loadNib("\(SSTHotBrandSectionHeadView.classForCoder())") as! UIView
                popularSectionHeadView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 30)
                return popularSectionHeadView
            } else if section >= topSectionTitles.count {
                let sectionTitleView = loadNib("\(SSTBrandSectionHeadView.classForCoder())") as! SSTBrandSectionHeadView
                var firstLetter = ""
                if let brands = brandData.brandGroups.validObjectAtIndex(section - topSectionTitles.count) as? [SSTBrand] {
                    firstLetter = validString(brands.first?.brandName.trim().sub(start: 0, end: 0))
                }
                if firstLetter.uppercased() < "A" || firstLetter.uppercased() > "Z" {
                    firstLetter = "#"
                }
                sectionTitleView.charLabel.text = firstLetter.uppercased()
                return sectionTitleView as UIView
            }
        default:
            break
        }
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if validString(topSectionTitles.validObjectAtIndex(section)) == kTitleAdvertisingProducts {
            if biz.hotProductData.advertisingProducts.count > 0 {
                return kHomeSlideHeight
            } else {
                return 0.01
            }
        }
        
        switch typeClicked {
        case .category:
            break
        case .brand:
            if validString(topSectionTitles.validObjectAtIndex(section)) == kTitlePopularBrands {
                return 30
            } else if section >= topSectionTitles.count {
                return 30
            }
        default:
            break
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if validString(topSectionTitles.validObjectAtIndex(indexPath.section)) == kTitleAdvertisingProducts {
            return 0.01
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if validString(topSectionTitles.validObjectAtIndex(indexPath.section)) == kTitleAdvertisingProducts {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(SSTCategoryViewCell.classForCoder())") as! SSTCategoryViewCell
        switch typeClicked {
        case .category:
            if let categodySub = categoryData.category?.subs?.validObjectAtIndex(indexPath.row) as? SSTCategory {
                cell.category = categodySub
                if categodySub.isLeaf {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                }
            }
        case .brand:
            cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            if validString(topSectionTitles.validObjectAtIndex(indexPath.section)) == kTitlePopularBrands {
                if let brand = brandData.brandsInHot.validObjectAtIndex(indexPath.row) as? SSTBrand {
                    cell.brand = brand
                }
            } else {
                if let brands = brandData.brandGroups.validObjectAtIndex(indexPath.section - topSectionTitles.count) as? [SSTBrand] {
                    if let brand = brands.validObjectAtIndex(indexPath.row) as? SSTBrand {
                        cell.brand = brand
                    }
                }
            }
        default :
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.productIdClicked = nil
        
        switch typeClicked {
        case .category:
            if let category = categoryData.category?.subs?.validObjectAtIndex(indexPath.row) as? SSTCategory {
                categoryClicked = category
                if category.isLeaf {
                    performSegueWithIdentifier(SegueIdentifier.SegueToSearchResult, sender: nil)
                } else {
                    performSegueWithIdentifier(SegueIdentifier.SegueToCategorySub, sender: nil)
                }
            }
        case .brand:
            var brands: [SSTBrand]?
            if validString(topSectionTitles.validObjectAtIndex(indexPath.section)) == kTitlePopularBrands {
                brands = brandData.brandsInHot
            } else if indexPath.section >= topSectionTitles.count {
                brands = brandData.brandGroups.validObjectAtIndex(indexPath.section - topSectionTitles.count) as? [SSTBrand]
            }
            if let tBrands = brands {
                if let brand = tBrands.validObjectAtIndex(indexPath.row) as? SSTBrand {
                    brandClicked = brand
                    performSegueWithIdentifier(SegueIdentifier.SegueToCategorySub, sender: nil)
                }
            }
        default:
            break
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if typeClicked == .brand {
            return kIndexLetters
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        for ind in 0 ..< brandData.brandGroups.count {
            if let brands = brandData.brandGroups.validObjectAtIndex(ind) as? [SSTBrand] {
                if validString(brands.first?.brandName.trim().sub(start: 0, end: 0)) == validString(kIndexLetters.validObjectAtIndex(index)) {
                    return ind + topSectionTitles.count
                }
            }
        }
        
        return index + topSectionTitles.count
    }
}


// MARK: -- segue delegate

extension SSTCategoryVC: SegueHandlerType {
    
    enum SegueIdentifier: String {
        case SegueToCategorySub     = "toCategorySub"
        case SegueToSearchResult    = "toSearchResult"
        case toItemDetails          = "toItemDetails"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch validString(segue.identifier) {
        case SegueIdentifier.SegueToCategorySub.rawValue:
            let destVC = segue.destination as! SSTCategoryTwoVC
            destVC.category = categoryClicked
            destVC.brand = brandClicked
            categoryClicked = nil
        case SegueIdentifier.toItemDetails.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            destVC.itemId = productIdClicked != nil ? productIdClicked : itemClicked?.id
        case SegueIdentifier.SegueToSearchResult.rawValue:
            let destVC = segue.destination as! SSTSearchResultVC
            destVC.category = categoryClicked
            destVC.searchKey = searchKey
            categoryClicked = nil
        default:
            break
        }
    }
}

// MARK: -- refresh delegate

extension SSTCategoryVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        if (data as? SSTHotProductData) == nil {
            SSTProgressHUD.dismiss(view: self.view)
        }
        
        if (data as? SSTCategoryData) != nil && self.typeClicked == CategoryOrBrand.category {
            self.tableView.endHeaderRefreshing(.success, delay: 0.5)
            self.tableView.reloadData()
            emptyView.isHidden = validInt(self.categoryData.category.subs?.count) <= 0 ? false : true
        } else if (data as? SSTBrandData) != nil && self.typeClicked == CategoryOrBrand.brand {
            self.tableView.endHeaderRefreshing(.success, delay: 0.5)
            self.tableView.reloadData()
            emptyView.isHidden = validInt(self.brandData.brands.count) <= 0 ? false : true
        } else if (data as? SSTHotProductData) != nil {
            self.tableView.reloadData()
        } else {
            self.tableView.endHeaderRefreshing(.failure, delay: 0.5)
        }
        
        emptyView.isHidden = tableView.numberOfSections > 0
    }
}
