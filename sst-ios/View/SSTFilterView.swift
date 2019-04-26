//
//  SSTFilterView.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/14.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kFilterViewTableViewRowHeight: CGFloat = 48

let kFilterViewLineTop: CGFloat = 3

class SSTFilterView: UIView, UITextFieldDelegate {
    
    enum fileType {
        case categorys
        case colors
        case carriers
    }
    
    var type:fileType = .categorys
    var excludeSoldOut: Bool?
    var priceRange: String?
    
    var categoryNames = [String]()
    var colorNames = [String]()
    var carriersNames = [String]()
    
    var categoriesButton: UIButton!
    var colorsButton: UIButton!
    var carriersButton: UIButton!
    
    var categoriesButtonTopLine : UIImageView!
    var leftLineV : UIImageView!
    var colorsButtonTopLine: UIImageView!
    var rightLineV: UIImageView!
    var carriersTopLine: UIImageView!

    var facets: [Facet]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var categoryFacets: [Facet]? {
        didSet {
            refreshGroupedCategoryFacets()
        }
    }
    var groupedCategoryFacets: [Facet]?
    
    var colorsFacets: [Facet]?
    var carriersFacets: [Facet]?
    
    var collapsedFacetKeys: [String] = [String]()
    
    func refreshGroupedCategoryFacets() {
        var tFacets = [Facet]()
        var prevGroupName = ""
        for facet in validArray(categoryFacets) as! [Facet] {
            var groupName = facet.key
            if facet.key.contains("$$$") {
                groupName = validString(facet.key.components(separatedBy: "$$$").first)
            }
            if groupName != prevGroupName {
                let nFacet = Facet(key: groupName, value: 0, type: "group", isExpanded: !collapsedFacetKeys.contains(groupName))
                tFacets.append(nFacet)
            }
            if !collapsedFacetKeys.contains(groupName) {
                tFacets.append(facet)
            }
            prevGroupName = groupName
        }
        groupedCategoryFacets = tFacets
    }
    
    var filterViewClick: ((_ excludeSoldOut: Bool?, _ priceRange: String?, _ groupTitle: [String]?, _ color: [String]?, _ carrierName: [String]?) -> Void)?
    
    @IBOutlet weak var excludeSoldOutSelcteButton: UIButton!
    @IBOutlet weak var excludeSoldOutButton: UIButton!
    @IBOutlet weak var priceRangeLowTF: UITextField!
    @IBOutlet weak var priceRangeHighTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let kSearchCellIdentifier = "SSTKeyValueCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.register(UINib(nibName: kSearchCellIdentifier, bundle:nil), forCellReuseIdentifier: kSearchCellIdentifier)
    }
    
    func findCategoryName(facetName: String) -> Int? {
        for ind in 0 ..< self.categoryNames.count {
            if facetName == validString(self.categoryNames.validObjectAtIndex(ind)) {
                return ind
            }
        }
        return nil
    }
    func findColorName(facetName: String) -> Int? {
        for ind in 0 ..< self.colorNames.count {
            if facetName == validString(self.colorNames.validObjectAtIndex(ind)) {
                return ind
            }
        }
        return nil
    }
    func findCarriersName(facetName: String) -> Int? {
        for ind in 0 ..< self.carriersNames.count {
            if facetName == validString(self.carriersNames.validObjectAtIndex(ind)) {
                return ind
            }
        }
        return nil
    }
    
    func addOrRemoveName(facetName: String) {
        switch type {
        case .categorys:
            if let ind = findCategoryName(facetName: facetName) {
                self.categoryNames.remove(at: ind)
            } else {
                self.categoryNames.append(facetName)
            }
        case .colors:
            if let ind = findColorName(facetName: facetName) {
                self.colorNames.remove(at: ind)
            } else {
                self.colorNames.append(facetName)
            }
        case .carriers:
            if let ind = findCarriersName(facetName: facetName) {
                self.carriersNames.remove(at: ind)
            } else {
                self.carriersNames.append(facetName)
            }
        }
    }
    
    func setButtonColor(){
        switch type {
        case .categorys:
            categoriesButton.setTitleColor(RGBA(0x70, g: 0x6f, b: 0xfd, a: 1), for: UIControlState())
            colorsButton.setTitleColor(UIColor.black, for: UIControlState())
            carriersButton.setTitleColor(UIColor.black, for: UIControlState())
            
            categoriesButtonTopLine?.image =  UIImage(named:"line_shang")
            colorsButtonTopLine?.image = UIImage(named:"line_xia")
            carriersTopLine?.image = UIImage(named:"line_xia")
            
            leftLineV.image = UIImage(named:"line_left")
            rightLineV.image = UIImage(named:"line_xia")
        case .colors:
            colorsButton.setTitleColor(RGBA(0x70, g: 0x6f, b: 0xfd, a: 1), for: UIControlState())
            categoriesButton.setTitleColor(UIColor.black, for: UIControlState())
            carriersButton.setTitleColor(UIColor.black, for: UIControlState())
            
            colorsButtonTopLine?.image =  UIImage(named:"line_shang")
            categoriesButtonTopLine?.image = UIImage(named:"line_xia")
            carriersTopLine?.image = UIImage(named:"line_xia")
            
            leftLineV.image = UIImage(named:"line_right")
            rightLineV.image = UIImage(named:"line_left")
        case .carriers:
            carriersButton.setTitleColor(RGBA(0x70, g: 0x6f, b: 0xfd, a: 1), for: UIControlState())
            categoriesButton.setTitleColor(UIColor.black, for: UIControlState())
            colorsButton.setTitleColor(UIColor.black, for: UIControlState())
            
            colorsButtonTopLine?.image =  UIImage(named:"line_xia")
            categoriesButtonTopLine?.image = UIImage(named:"line_xia")
            carriersTopLine?.image = UIImage(named:"line_shang")
            
            leftLineV.image = UIImage(named:"line_xia")
            rightLineV.image = UIImage(named:"line_right")
        }
    }
    
    @objc func categoriesButtonEvent(){
        type = .categorys
        setButtonColor()
        facets = groupedCategoryFacets
    }
    @objc func colorsButtonEvent(){
        type = .colors
        setButtonColor()
        facets = colorsFacets
    }
    @objc func carriersButtonEvent(){
        type = .carriers
        setButtonColor()
        facets = carriersFacets
    }
    
    @IBAction func clickedClearAllButton(_ sender: Any?) {
        excludeSoldOutSelcteButton.isSelected = false
        excludeSoldOutButton.isSelected = false
        priceRangeLowTF.text = ""
        priceRangeHighTF.text = ""
        
        self.categoryNames.removeAll()
        self.colorNames.removeAll()
        self.carriersNames.removeAll()
        
        self.tableView.reloadData()
        
        self.filterViewClick?(nil, nil, nil,nil,nil)
    }
    
    @IBAction func clickedOKButton(_ sender: Any) {
        var priceRange = ""
        let lowPrice = validMoney(priceRangeLowTF.text) > kOneInMillion ? validMoney(priceRangeLowTF.text).formatMoney() : ""
        let highPrice = validString(priceRangeHighTF.text).trim().isNotEmpty ? validMoney(priceRangeHighTF.text).formatMoney() : ""
        if lowPrice.isNotEmpty || highPrice.isNotEmpty {
            priceRange = "[\(lowPrice.isEmpty ? "*" : lowPrice) TO \(highPrice.isEmpty ? "*" : highPrice)]"
        }
        self.filterViewClick?(excludeSoldOutButton.isSelected, priceRange, self.categoryNames, self.colorNames, self.carriersNames)
    }
    
    @IBAction func clickedExcludeSoldOutSelectButton(_ sender: Any) {
        excludeSoldOutSelcteButton.isSelected = !excludeSoldOutSelcteButton.isSelected
        excludeSoldOutButton.isSelected = excludeSoldOutSelcteButton.isSelected
    }
    
    @IBAction func clickedExcludeSoldOutButton(_ sender: Any) {
        clickedExcludeSoldOutSelectButton(sender)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
        
        if toBeString.isNotEmpty && validBool(toBeString.isValidMoney) == false {
            return false
        } else if toBeString.count > 10 {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func getHeadButtonsView() -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: kFilterViewTableViewRowHeight))
        view.backgroundColor = UIColor.white
        
        categoriesButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.frame.width/3 - 5, height: kFilterViewTableViewRowHeight - 2))
        categoriesButton.setTitle("Categories", for: UIControlState())
        categoriesButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        categoriesButton.setTitleColor(UIColor.black, for: UIControlState())
        categoriesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        categoriesButton.addTarget(self, action: #selector(SSTFilterView.categoriesButtonEvent), for: .touchUpInside)
        
        categoriesButtonTopLine = UIImageView(frame: CGRect(x: 0, y: kFilterViewLineTop, width: categoriesButton.width , height: categoriesButton.height - kFilterViewLineTop * 2))
        categoriesButtonTopLine.image = UIImage(named:"line_shang")
        categoriesButtonTopLine.alpha = 0.3
        view.addSubview(categoriesButtonTopLine)
        
        leftLineV = UIImageView(frame: CGRect(x: categoriesButton.frame.maxX, y: kFilterViewLineTop, width: 10, height: categoriesButton.frame.size.height - kFilterViewLineTop * 2))
        leftLineV.image = UIImage(named: "line_left")
        leftLineV.alpha = 0.5
        view.addSubview(leftLineV)
        
        colorsButton = UIButton(frame: CGRect(x: leftLineV.frame.maxX, y: 0, width: self.frame.width/3 - 16, height: kFilterViewTableViewRowHeight - 2))
        colorsButton.setTitle("Colors", for: UIControlState())
        colorsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        colorsButton.setTitleColor(UIColor.black, for: UIControlState())
        colorsButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center;
        colorsButton.addTarget(self, action: #selector(SSTFilterView.colorsButtonEvent), for: .touchUpInside)
        
        colorsButtonTopLine = UIImageView(frame: CGRect(x: colorsButton.frame.minX, y: kFilterViewLineTop, width: colorsButton.width , height: colorsButton.height - kFilterViewLineTop * 2))
        colorsButtonTopLine.image = UIImage(named:"line_xia")
        colorsButtonTopLine.alpha = 0.3
        view.addSubview(colorsButtonTopLine)
        
        let color_carr = UIImageView(frame: CGRect(x: colorsButton.frame.maxX, y: kFilterViewLineTop, width: 10, height: colorsButton.frame.size.height - kFilterViewLineTop * 2))
        color_carr.image = UIImage(named:"line_xia")
        color_carr.alpha = 0.3
        view.addSubview(color_carr)
        rightLineV = color_carr
        
        carriersButton = UIButton(frame: CGRect(x: color_carr.frame.maxX, y: 0, width: self.frame.width/3 - 13, height: kFilterViewTableViewRowHeight - 2))
        carriersButton.setTitle("Carriers", for: UIControlState())
        carriersButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        carriersButton.setTitleColor(UIColor.black, for: UIControlState())
        carriersButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center;
        carriersButton.addTarget(self, action: #selector(SSTFilterView.carriersButtonEvent), for: .touchUpInside)
        
        carriersTopLine = UIImageView(frame: CGRect(x: carriersButton.frame.minX, y: kFilterViewLineTop, width: carriersButton.width, height: carriersButton.height - kFilterViewLineTop * 2))
        carriersTopLine.image = UIImage(named:"line_xia")
        carriersTopLine.alpha = 0.5
        view.addSubview(carriersTopLine)
        
        view.addSubview(categoriesButton)
        view.addSubview(colorsButton)
        view.addSubview(carriersButton)
        
        setButtonColor()
        
        return view
    }
}

// MARK: -- UITableViewDelegate

extension SSTFilterView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return validInt(facets?.count)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderAtIndexPath indexPath: IndexPath) -> CGFloat {
        return kFilterViewTableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return kFilterViewTableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kFilterViewTableViewRowHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return getHeadButtonsView()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kSearchCellIdentifier) as? SSTKeyValueCell
        if cell == nil {
            cell = loadNib(kSearchCellIdentifier) as? SSTKeyValueCell
        }
        
        let cellFacet = facets?.validObjectAtIndex(indexPath.row) as? Facet
        if let tFacet = cellFacet {
            if type == .categorys {
                cell?.setCategoryFacet(facet: tFacet)
            } else {
                cell?.setFacet(facet: tFacet)
            }
        }
        
        var isSelected = false
        switch type {
        case .categorys:
            isSelected = validString(cellFacet?.type) != "group" && findCategoryName(facetName: validString(cellFacet?.key)) != nil
        case .colors:
            isSelected = findColorName(facetName: validString(cellFacet?.key)) != nil
        case .carriers:
            isSelected = findCarriersName(facetName: validString(cellFacet?.key)) != nil
        }
        if isSelected {
            cell?.keyLabel.textColor = RGBA(0x70, g: 0x6f, b: 0xfd, a: 1)
            cell?.countLabel.textColor = RGBA(0x70, g: 0x6f, b: 0xfd, a: 1)
            cell?.backgroundColor = RGBA(0x70, g: 0x6f, b: 0xfd, a: 0.2)
        } else {
            cell?.countLabel.textColor = UIColor.black
            cell?.backgroundColor = UIColor.clear
        }
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let tmpFacet = facets?.validObjectAtIndex(indexPath.row) as? Facet {
            if type == .categorys && tmpFacet.type == "group" {
                for ind in 0 ..< collapsedFacetKeys.count {
                    if tmpFacet.key == collapsedFacetKeys[ind] {
                        collapsedFacetKeys.remove(at: ind)
                        break
                    }
                }
                if tmpFacet.isExpanded {
                    collapsedFacetKeys.append(tmpFacet.key)
                }
                refreshGroupedCategoryFacets()
                self.facets = self.groupedCategoryFacets
            } else {
                addOrRemoveName(facetName: tmpFacet.key)
            }
        }
        
        tableView.reloadData()
    }
}
