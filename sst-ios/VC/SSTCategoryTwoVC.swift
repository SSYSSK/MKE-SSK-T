//
//  SSTCategoryTwoVC.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/8/24.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTCategoryTwoVC: SSTBaseSearchVC {
    
    var category: SSTCategory?
    var parentCategory: SSTCategory?
    var brand: SSTBrand?
    var series: SSTSeries?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleView: UIView!
    
    fileprivate var categoryData = SSTCategoryData()
    fileprivate var seriesDara = SSTSeriesData()
    fileprivate var devicesData = SSTDevicesData()
    fileprivate var hotProductData = SSTHotProductData()
    
    fileprivate let kCategoryCellName = "\(SSTCategoryTwoView.classForCoder())"
    fileprivate let kCategoryBrandHeadViewName = "\(SSTCategoryBrandHeadView.classForCoder())"
    
    fileprivate var productIdClicked: String?
    fileprivate var categoryClicked: SSTCategory?
    fileprivate var seriesClicked: SSTSeries?
    fileprivate var deviceClicked: SSTDevices?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: kCategoryCellName, bundle:nil), forCellReuseIdentifier: kCategoryCellName)
        tableView.register(UINib(nibName: kCategoryBrandHeadViewName, bundle:nil), forCellReuseIdentifier: kCategoryBrandHeadViewName)
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        categoryData.delegate = self
        seriesDara.delegate = self
        devicesData.delegate = self
        hotProductData.delegate = self
        
        fetchData()
        
        let refreshHeaderView = SSTRefreshHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height:70))
        _ = self.tableView.setUpHeaderRefresh(refreshHeaderView) { [weak self] in
            self?.fetchData()
        }
        
        self.titleView.frame = CGRect(x: 0, y: 0, width: kSearchResultTitleViewWidth, height: 30)
        self.titleView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.categoryClicked = nil
        self.deviceClicked = nil
        self.searchKey = nil
        
        setTitle()
    }
    
    func setTitle() {
        for subV in self.titleView.subviews {
            subV.removeFromSuperview()
        }
        
        var title = ""
        if category != nil {
            if parentCategory == nil {
                title = clearName("\(validString(category?.name))")
            } else {
                title = clearName("\(validString(parentCategory?.name)) > \(validString(category?.name))")
            }
        } else if brand != nil {
            title = clearName(validString(brand?.brandName))
        } else if series != nil {
            title = clearName(validString(series?.seriesName))
        }
        
        let titleLabel = UILabel(frame: CGRect(x:0, y:0, width:5000, height:30))
        titleLabel.textColor = kNavigationBarForegroundColor
        titleLabel.font = kNavigationBarFont
        
        if title.sizeByFont(font: kNavigationBarFont).width <= kSearchResultTitleViewWidth {
            titleLabel.frame.size = CGSize(width: kSearchResultTitleViewWidth, height: 30)
            titleLabel.textAlignment = .center
            titleLabel.text = title
        } else {
            titleLabel.textAlignment = .left
            let title1 = "\(title)             "
            let title2 = "\(title1)\(title)"
            let title1Width = title1.sizeByFont(font: kNavigationBarFont).width
            titleLabel.text = title2
            
            TaskUtil.delayExecuting(1, block: {
                UIView.beginAnimations("CategoryTitle", context: nil)
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
    
    override func fetchData() {
        if category != nil {
            SSTProgressHUD.show(view: self.view)
            categoryData.fetchData(parentId: category?.id)
            hotProductData.getHotProductsInCategory(validInt(category?.groupId))
            self.title = clearName(validString(category?.name))
        } else if brand?.brandId != nil {
            SSTProgressHUD.show(view: self.view)
            seriesDara.getSeriess(brandId: validInt(brand?.brandId))
            hotProductData.getHotProductsInBrand(validInt(brand?.brandId))
            self.title = clearName(validString(brand?.brandName))
        } else if series?.seriesId != nil {
            SSTProgressHUD.show(view: self.view)
            devicesData.getDevices(seriesId: validInt(series?.seriesId))
            hotProductData.getHotProductsInSeries(validInt(series?.seriesId))
            self.title = clearName(validString(series?.seriesName))
        }
    }
}

// MARK: -- tableView delegate

extension SSTCategoryTwoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            if category != nil {
                return validInt(categoryData.category?.subs?.count)
            } else if brand != nil {
                return seriesDara.seriess.count
            } else if series != nil {
                return devicesData.devicess.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if hotProductData.hotProducts.count <= 0 {
            return 0.1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if hotProductData.hotProducts.count > 0 {
                return kHomeSlideHeight
            } else {
                return 0
            }
        }
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCategoryBrandHeadViewName) as! SSTCategoryBrandHeadView
            cell.setParas(hotProductData.hotProducts, itemWidth: kScreenWidth , itemHeight: kHomeSlideHeight, placeholder: kIcon_slide)
            cell.itemClick = { item in
                if let tmpHotProduct = item as? SSTHotProduct {
                    self.productIdClicked = tmpHotProduct.productId
                    self.performSegueWithIdentifier(SegueIdentifier.toItemDetails, sender: nil)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: kCategoryCellName) as! SSTCategoryTwoView
            cell.nameL.highlightedTextColor = systemColor
            
            if category != nil {
                if let categodySub = categoryData.category?.subs?.validObjectAtIndex(indexPath.row) as? SSTCategory {
                    cell.category = categodySub
                    if categodySub.isLeaf {
                        cell.accessoryType = UITableViewCellAccessoryType.none
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                    }
                }
            } else if brand != nil {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
                if let tSeries = seriesDara.seriess.validObjectAtIndex(indexPath.row) as? SSTSeries {
                    cell.series = tSeries
                }
            } else if series != nil {
                cell.accessoryType = UITableViewCellAccessoryType.none
                if let tDevice = devicesData.devicess.validObjectAtIndex(indexPath.row) as? SSTDevices {
                    cell.devices = tDevice
                }
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if category != nil {
            categoryClicked = categoryData.category?.subs?.validObjectAtIndex(indexPath.row) as? SSTCategory
            if validBool(categoryClicked?.isLeaf) {
                performSegueWithIdentifier(SegueIdentifier.SegueToSearchResult, sender: nil)
            } else {
                performSegueWithIdentifier(SegueIdentifier.SegueToCategorySub, sender: nil)
            }
        } else if brand != nil {
            if let tSeries = seriesDara.seriess.validObjectAtIndex(indexPath.row) as? SSTSeries {
                seriesClicked = tSeries
                performSegueWithIdentifier(SegueIdentifier.SegueToCategorySub, sender: nil)
            }
        } else if series != nil {
            if let tDevice = devicesData.devicess.validObjectAtIndex(indexPath.row) as? SSTDevices {
                deviceClicked = tDevice
                performSegueWithIdentifier(SegueIdentifier.SegueToSearchResult, sender: nil)
            }
        }
    }
}

// MARK: -- segue delegate

extension SSTCategoryTwoVC: SegueHandlerType {
    
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
            destVC.parentCategory = self.category
            destVC.series = seriesClicked
        case SegueIdentifier.toItemDetails.rawValue:
            let destVC = segue.destination as! SSTItemDetailVC
            destVC.itemId = productIdClicked != nil ? productIdClicked : itemClicked?.id
        case SegueIdentifier.SegueToSearchResult.rawValue:
            let destVC = segue.destination as! SSTSearchResultVC
            if categoryClicked != nil {
                destVC.parentCategory = category
                destVC.category = categoryClicked
            } else if deviceClicked != nil {
                destVC.parentDeviceName = series != nil ? series?.seriesName : brand?.brandName
                destVC.device = deviceClicked
            } else {
                destVC.searchKey = searchKey
            }
        default:
            break
        }
    }
}

// MARK: -- SSTUIRefreshDelegate

extension SSTCategoryTwoVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        if (data as? SSTHotProductData) != nil {
            //
        } else {
            SSTProgressHUD.dismiss(view: self.view)
        }
        
        if (data as? SSTCategoryData) != nil {
            self.tableView.endHeaderRefreshing(.success, delay: 0.5)
            self.tableView.reloadData()
        } else if (data as? SSTSeriesData) != nil {
            self.tableView.endHeaderRefreshing(.success, delay: 0.5)
            self.tableView.reloadData()
        } else if (data as? SSTDevicesData) != nil {
            self.tableView.endHeaderRefreshing(.success, delay: 0.5)
            self.tableView.reloadData()
        } else if (data as? SSTHotProductData) != nil {
            self.tableView.reloadData()
        } else {
            self.tableView.endHeaderRefreshing(.failure, delay: 0.5)
        }
    }
}
