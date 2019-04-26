//
//  SSTCategoryDetailView.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/21/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SSTCategoryDetailView: UIView{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var categoryClick: ((_ category: SSTCategory?) -> Void)?
    
    fileprivate let cellIdentifier = "CategoryCell"
    
    var levelObject: SSTLevelObject? {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: "SSTCategoryDetailViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    fileprivate func collapse(_ currentLevelObj: SSTLevelObject, indexPathRow: Int) {
        if let subs = currentLevelObj.subs {
            for subObj in subs {
                let row = indexPathRow + 1
                let indPath = IndexPath(row: row, section: 0)
                if subObj.isExpanded == true && subObj.subs?.count > 0 {
                    collapse(subObj, indexPathRow: row)
                }
                levelObject?.subs?.remove(at: row)
                tableView.deleteRows(at: [indPath], with: UITableViewRowAnimation.top)
            }
        }
        currentLevelObj.isExpanded = false
    }
    
    @IBAction func didClickedLeftMaskView(_ sender: AnyObject) {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight - 15)
            }, completion: { (Bool) in
                self.categoryClick?(nil)
        })
    }
    
}

//MAKR:-- tableView delegate
extension SSTCategoryDetailView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validInt(levelObject?.subs?.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SSTCategoryDetailViewCell
        if let obj = levelObject?.subs?.validObjectAtIndex(indexPath.row) as? SSTLevelObject {
            cell.levelObject = obj
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentLevelObj = levelObject?.subs?[indexPath.row]
        let currentCategory = levelObject?.subs?[indexPath.row].obj as? SSTCategory
        
        if validInt(currentLevelObj?.subs?.count) == 0 {
            self.categoryClick?(currentCategory)
        } else {
            if currentLevelObj?.isExpanded == true {
                collapse(currentLevelObj!, indexPathRow: indexPath.row)
            } else {
                for index in 0 ..< validInt(currentLevelObj?.subs?.count) {
                    let row = indexPath.row + index + 1
                    let indPath = IndexPath(row: row, section: 0)
                    if let tmpLevelObject = currentLevelObj?.subs?[index] {
                        levelObject?.subs?.insert(tmpLevelObject, at: row)
                        tableView.insertRows(at: [indPath], with: UITableViewRowAnimation.top)
                    }
                }
                currentLevelObj?.isExpanded = true
            }
            let cell = tableView.cellForRow(at: indexPath) as! SSTCategoryDetailViewCell
            cell.levelObject = currentLevelObj
        }
    }
}
