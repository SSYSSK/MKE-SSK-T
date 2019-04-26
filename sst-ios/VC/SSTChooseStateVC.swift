//
//  SSTChooseStateVC.swift
//  sst-ios
//
//  Created by Amy on 16/7/11.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTChooseStateVC: SSTBaseVC, UITableViewDataSource, UITableViewDelegate {

    var stateData: [SSTState]! {
        didSet {
            for state in stateData {
                if let group = SSTGroup.findGroup(name: validString(state.name?.sub(start: 0, end: 0)), within: self.groups) {
                    group.items.append(state)
                } else {
                    let nGroup = SSTGroup(validString(state.name?.sub(start: 0, end: 0)))
                    nGroup.items.append(state)
                    self.groups.append(nGroup)
                }
            }
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var groups = [SSTGroup]()

    fileprivate var filterdData = [SSTState]() { // 搜索数据
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var selectedState = ""
    var searchController: UISearchController!
    var chooseStateBlock:((_ state: String,_ code: String) ->Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.tableView.sectionIndexBackgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
    }
    
    // MARK: -- UITableViewDataSource, UITableViewDelegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if validString(searchBar.text?.trim()).isEmpty {
            return self.groups.count
        } else {
            return filterdData.count > 0 ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if validString(searchBar.text?.trim()).isEmpty {
            return validInt((self.groups.validObjectAtIndex(section) as? SSTGroup)?.items.count)
        } else {
            return filterdData.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title = ""
        if validString(searchBar.text?.trim()).isEmpty {
            title = self.groups[section].name
        } else {
            title = "Top Name Matches"
        }
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 0, width: kScreenWidth, height: 30))
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 13)
        
        let titleView = UIView(frame: CGRect(x: 0, y:0, width:kScreenWidth, height:30))
        titleView.addSubview(titleLabel)
        titleView.backgroundColor = UIColor.groupTableViewBackground
        return titleView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var stateInfo: SSTState!
        if validString(searchBar.text?.trim()).isEmpty {
            stateInfo = groups[indexPath.section].items[indexPath.row] as! SSTState
        } else {
            stateInfo = filterdData[indexPath.row]
        }
        
        if tableView == self.tableView {
            if let cell = tableView.dequeueCell(SSTChooseStateCell.self) {
                cell.name.text = stateInfo.name
                if stateInfo.name == selectedState {
                    cell.name.textColor = UIColor.red
                } else {
                    cell.name.textColor = UIColor.black
                }
                return cell
            } else {
                return UITableViewCell()
            }
        } else {
            tableView.backgroundColor = UIColor.groupTableViewBackground
            tableView.sectionIndexBackgroundColor = UIColor.clear
            
            let cell = UITableViewCell()
            cell.textLabel?.text = stateInfo.name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
            if stateInfo.name == selectedState {
                cell.textLabel?.textColor = UIColor.red
            } else {
                cell.textLabel?.textColor = UIColor.black
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {var stateInfo: SSTState!
        if validString(searchBar.text?.trim()).isEmpty {
            stateInfo = groups[indexPath.section].items[indexPath.row] as! SSTState
        } else {
            stateInfo = filterdData[indexPath.row]
        }
        
        if let block = chooseStateBlock  {
            block(validString(stateInfo.name), validString(stateInfo.code))
            _ = navigationController?.popViewController(animated: true)
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if tableView == self.tableView {
            return kIndexLetters
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        for ind in 0 ..< groups.count {
            if groups[ind].name == validString(kIndexLetters.validObjectAtIndex(index)) {
                return ind
            }
        }
        
        return index
    }

}

extension SSTChooseStateVC: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if validInt(searchBar.text?.count) == 0 {
            tableView.reloadData()
            return
        }
        self.filterdData = self.stateData.filter { (state) -> Bool in
            return (validString(state.name).contains(validString(searchBar.text)))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
}
