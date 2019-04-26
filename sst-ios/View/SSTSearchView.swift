//
//  SSTSearchView.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/18/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTSearchView: UIView, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBarBgView: UIImageView!
    @IBOutlet weak var searchTextField: SSTSearchTextField!
    @IBOutlet weak var deleteTextButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var itemData = SSTItemData()
    
    fileprivate let kSearchCellIdentifier = "SSTSearchViewCell"
    fileprivate let kItemCellIdentifier = "ItemCellIdentifier"
    
    fileprivate var sectionsExpanded = [Int]()
    
    var backFromSearch: ((_ searchKey: String?, _ item: SSTItem?) -> Void)?
    
    fileprivate var searchTask: AsynTask?
    
    fileprivate var isHistoryShowing: Bool {
        get {
            return validString(searchTextField.text).trim().count == 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemData.delegate = self
        
        tableView.register(UINib(nibName: kSearchCellIdentifier, bundle:nil), forCellReuseIdentifier: kSearchCellIdentifier)
        searchBarBgView.image = getNavigationBarBgImage()
        searchTextField.delegate = self
        searchTextField.returnKeyType = UIReturnKeyType.search
        searchTextField.enablesReturnKeyAutomatically = true
        searchTextField.becomeFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString = validString((validString(textField.text) as NSString).replacingCharacters(in: range, with: string)).trim()
        if toBeString.count <= 0 {
            deleteTextButton.isHidden = true
            searchTextField.text = ""
            tableView.reloadData()
            return false
        } else {
            deleteTextButton.isHidden = false
            TaskUtil.cancel(searchTask)
            searchTask = TaskUtil.delayExecuting(0.5) {
                self.itemData.searchItemsWithPrefix(toBeString)
            }
            return true
        }
    }
    
    @IBAction func clickedDeleteTextButton(_ sender: AnyObject) {
        searchTextField.text = ""
        deleteTextButton.isHidden = true
        tableView.reloadData()
    }
    
    @IBAction func clickedCancelButton(_ sender: AnyObject) {
        self.removeFromSuperview()
        self.backFromSearch?(nil, nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard validString(textField.text).trim() != "" else {
            ToastUtil.showToast("No valid string to search")
            return false
        }
        self.removeFromSuperview()
        if self.backFromSearch != nil && validString(searchTextField.text) != "" {
            self.backFromSearch?(validString(searchTextField.text), nil )
        }
        return true
    }
    
    @objc func clickedTableViewHeaderView(_ button: UIButton) {
        let section: Int = button.tag
        
        if sectionsExpanded.contains(section) {
            for ind in 0 ..< sectionsExpanded.count {
                if validInt(sectionsExpanded.validObjectAtIndex(ind)) == section {
                    sectionsExpanded.remove(at: ind)
                    break
                }
            }
        } else {
            sectionsExpanded.append(section)
        }
        tableView.reloadSections(IndexSet(integer: section), with: UITableViewRowAnimation.automatic)
    }

    // MARK:-- tableView delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isHistoryShowing {
            if itemData.historyKeywords.count > 0 {
                return 1
            } else {
                return 0
            }
        } else {
            if let groups = itemData.groups {
                return groups.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isHistoryShowing {
            if itemData.historyKeywords.count > 0 {
                return itemData.historyKeywords.count + 1
            } else {
                return 0
            }
        } else {
            if sectionsExpanded.contains(section) {
                if let group = itemData.groups?.validObjectAtIndex(section) as? SSTGroup {
                    return group.items.count
                } else {
                    return 0
                }
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
        
        if isHistoryShowing {
            
            let label = UILabel.init(frame: CGRect(x: 15, y: 10, width: kScreenWidth - 20, height: 20))
            label.font = UIFont.systemFont(ofSize: 13)
            label.text = "Search History"
            
            headerView.addSubview(label)
            headerView.backgroundColor = UIColor.groupTableViewBackground
        } else {
            
            let tempV = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
            let textlabel = UILabel(frame: CGRect(x: 15, y: 10, width: kScreenWidth-20, height: 20))
            textlabel.font = UIFont.systemFont(ofSize: 13)
            textlabel.text = validString(itemData.groups?[section].name)
            tempV.addSubview(textlabel)
            
            let iamgeView = UIImageView()
            if sectionsExpanded.contains(section) {
                iamgeView.frame = CGRect(x: kScreenWidth-25, y: 16, width: 15, height: 7)
                iamgeView.image = UIImage(named:kIconExpandImageName)
            } else {
                iamgeView.frame = CGRect(x: kScreenWidth-20, y: 13, width: 7, height: 14)
                iamgeView.image = UIImage(named: kIconGoInImageName);
            }
            tempV.addSubview(iamgeView)
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 40))
            button.addTarget(self, action: #selector(SSTSearchView.clickedTableViewHeaderView(_:)), for: UIControlEvents.touchUpInside)
            button.tag = section
            tempV.addSubview(button)

            let linelabel = UILabel(frame: CGRect(x: 0, y: 39, width: kScreenWidth, height: 1))
            linelabel.backgroundColor = UIColor.groupTableViewBackground

            tempV.addSubview(linelabel)
            
            headerView.addSubview(tempV)
            headerView.backgroundColor = UIColor.white
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isHistoryShowing {
            let cell = tableView.dequeueReusableCell(withIdentifier: kSearchCellIdentifier) as! SSTSearchViewCell
            cell.lineView.isHidden = false
            cell.nameL.textColor = RGBA(128, g: 128, b: 128, a: 1)
            if indexPath.row == itemData.historyKeywords.count {
                cell.lineView.isHidden = true
                cell.nameL.textColor = RGBA(65, g: 105, b: 225, a: 1)
                cell.name = "Clear All"
            } else {
                if indexPath.row >= itemData.historyKeywords.count {
                    
                } else {
                    cell.name = itemData.historyKeywords[indexPath.row]
                }
            }
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: kItemCellIdentifier)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: kItemCellIdentifier)
            }
            if let tCell = cell {
                let nameLabel = UILabel(frame: CGRect(x: 40, y: 10, width: kScreenWidth - 60, height: 20))
                nameLabel.font = UIFont.systemFont(ofSize: 12)
                nameLabel.tag = 1001
                tCell.addSubview(nameLabel)
                
                let bottomLine = UIView(frame: CGRect(x: 40, y: 39, width: kScreenWidth - 40, height: 1))
                bottomLine.backgroundColor = UIColor.groupTableViewBackground
                tCell.addSubview(bottomLine)
                
                if let group = itemData.groups?.validObjectAtIndex(indexPath.section) as? SSTGroup {
                    if let item = group.items.validObjectAtIndex(indexPath.row) as? SSTItem {
                        (tCell.viewWithTag(1001) as! UILabel).text = item.name
                    }
                }
                
                return tCell
            }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isHistoryShowing {
            if indexPath.row < itemData.historyKeywords.count {
                self.removeFromSuperview()
                self.backFromSearch?(validString(itemData.historyKeywords.validObjectAtIndex(indexPath.row)), nil)
            } else {
                itemData.removeAllHistory()
                tableView.reloadData()
            }
        } else {
            if let group = itemData.groups?.validObjectAtIndex(indexPath.section) as? SSTGroup {
                if let item = group.items.validObjectAtIndex(indexPath.row) as? SSTItem {
                    self.removeFromSuperview()
                    self.backFromSearch?(nil, item)
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
}

// MARK: -- refreshUI delegate
extension SSTSearchView: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        sectionsExpanded.removeAll()
        tableView.reloadData()
    }
}

