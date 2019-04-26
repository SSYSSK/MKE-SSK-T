//
//  SSTBaseSearchVC.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/8/26.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTBaseSearchVC: SSTBaseVC {
    
    fileprivate enum SegueIdentifier: String {
        case toSearchResult    = "toSearchResult"
        case toItemDetails     = "toItemDetails"
        
    }
    var searchKey: String?
    var itemClicked: SSTItem?
    var itemIndClicked: Int?
    
    @IBAction func clickedSearchBarButton(_ sender: Any?) {
        
        let searchVC = loadVC(controllerName: "SSTSearchVC", storyboardName: "Search") as! SSTSearchVC
        let window = UIApplication.shared.delegate?.window
        window??.rootViewController?.present(searchVC, animated: false, completion: nil)

        searchVC.itemData.refreshHistoryKeywords()
        
        if self.isKind(of: SSTSearchResultVC.classForCoder()) {
            searchVC.searchTextField.text = searchKey
            searchVC.itemData.searchItemsWithPrefix(validString(searchVC.searchTextField.text))
        } else {
            searchVC.searchTextField.text = ""
            searchVC.tableView.reloadData()
        }
        searchVC.deleteTextButton.isHidden = validString(searchVC.searchTextField.text).trim().count > 0 ? false : true
        searchVC.searchTextField.becomeFirstResponder()
        
        searchVC.backFromSearch = { searchKey, item in
            if searchKey != nil {
                self.searchKey = searchKey
                if let searchResultVC = self as? SSTSearchResultVC {
                    searchResultVC.category = nil
                    searchResultVC.device = nil
                    searchResultVC.filterView.clickedClearAllButton(nil)
                    searchResultVC.resetPriceButton()
                    searchResultVC.searchItems(facet:"1")
                    searchResultVC.setTitle()
                } else {
                    self.performSegue(withIdentifier: "\(SegueIdentifier.toSearchResult.rawValue)", sender: self)
                }
            } else if item != nil {
                if let txt = searchVC.searchTextField.text?.trim() {
                    SSTItemData().insertHistoryKeywords([txt])
                }
                self.itemClicked = item
                self.performSegue(withIdentifier: "\(SegueIdentifier.toItemDetails.rawValue)", sender: self)
            }
            appDelegate.window?.makeKeyAndVisible()
        }
    }
}

