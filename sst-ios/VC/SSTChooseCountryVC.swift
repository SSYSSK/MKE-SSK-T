//
//  SSTChooseCountryTVC.swift
//  sst-ios
//
//  Created by Amy on 16/7/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTChooseCountryVC: SSTBaseVC {
    
    var selectedCountry = String()
    
    var countriesInfo = SSTCountryData() {
        didSet {
            for group in countriesInfo.groups {
                sectionTitle.append(validString(group.name))
            }
        }
    }
    
    fileprivate var sectionTitle = [String]()
    fileprivate var filterdData = [SSTCountry]()
    fileprivate var states = [String]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var myTableView: UITableView!
    
    var chooseCountryBlock:((_ country: SSTCountry) -> Void)?
    var shouldShowSearchResults = false //是否显示搜索结果
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            myTableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        myTableView.sectionIndexBackgroundColor = UIColor.clear
    }
    
    func updateSearchResults(key: String) {
        guard key.isNotEmpty else {
            return
        }
        shouldShowSearchResults = true
        var countries = [SSTCountry]()
        
        let searchString = key.lowercased()
        for index in 0...sectionTitle.count - 1 {
            let groups = countriesInfo.groups[index]
            for ind in 0...groups.countries.count - 1 {
                let country: SSTCountry = groups.countries[ind]
                if ((country.name?.lowercased().range(of: searchString)) != nil) || ((country.code?.lowercased().range(of: searchString)) != nil) {
                    countries.append(country)
                }
            }
        }
        
        countries.sort(by: { (c1, c2) -> Bool in
            validString(c1.name) < validString(c2.name)
        })
        
        filterdData = countries
    }
    
    @IBAction func clickedUnitedStatesButton(_ sender: Any) {
        if let block = chooseCountryBlock {
            for group in self.countriesInfo.groups {
                for country in group.countries {
                    if country.name == "United States" {
                        block(country)
                        _ = navigationController?.popViewController(animated: true)
                        return
                    }
                }
            }
            
        }
    }
}

extension SSTChooseCountryVC: UITableViewDataSource,UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        if shouldShowSearchResults {
            if filterdData.count > 0 {
                return 1
            } else {
                return 0
            }
        }
        return countriesInfo.groups.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if shouldShowSearchResults {
            return nil
        }
        return sectionTitle
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        if shouldShowSearchResults {
            title = "Top Name Matches"
        } else {
            title = sectionTitle[section]
        }
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: kScreenWidth, height: 30))
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        
        let titleView = UIView(frame: CGRect(x: 0, y:0, width:kScreenWidth, height:30))
        titleView.addSubview(titleLabel)
        titleView.backgroundColor = UIColor.groupTableViewBackground
        return titleView
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        var count = 0
        for character in sectionTitle {
            //判断索引值和组名称相等，返回组坐标
            if character == title{
                return count
            }
            count += 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var group: SSTCountryGroup!
        if shouldShowSearchResults {
            return filterdData.count
        } else {
            group = countriesInfo.groups[section]

        }
        return group.countries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var country: SSTCountry!
        if shouldShowSearchResults {
            country = filterdData[indexPath.row]
        } else {
            country = countriesInfo.groups[indexPath.section].countries[indexPath.row]
        }
        
        if tableView == myTableView {
            var cell = tableView.dequeueCell(SSTChooseCountryCell.self)
            if nil == cell {
                cell = loadNib("\(SSTChooseCountryCell.classForCoder())") as? SSTChooseCountryCell
            }
            
            cell?.name.text = country.name
            if country.name == selectedCountry {
                cell?.name.textColor = UIColor.red
            } else {
                cell?.name.textColor = UIColor.black
            }
            return cell!
        } else {
            tableView.backgroundColor = UIColor.groupTableViewBackground
            tableView.sectionIndexBackgroundColor = UIColor.clear
            
            let cell = UITableViewCell()
            cell.textLabel?.text = country.name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            if country.name == selectedCountry {
                cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var country: SSTCountry!
        if shouldShowSearchResults {
            country = filterdData[indexPath.row]
        } else {
            country = countriesInfo.groups[indexPath.section].countries[indexPath.row]
        }
        
        if let block = chooseCountryBlock {
            block(country)
            _ = navigationController?.popViewController(animated: true)
        }
    }
}

extension SSTChooseCountryVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard validInt(searchBar.text?.count) > 0 else {
            return
        }
        shouldShowSearchResults = true
        updateSearchResults(key: validString(searchBar.text))
    }
    
    //点击cancel，设置不显示搜索结果并刷新列表
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        myTableView.reloadData()
    }
    
    //点击搜索，出发代理，如果已经显示搜索结果，则直接去掉键盘，否则刷新列表
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
