//
//  SSTCountryData.swift
//  sst-ios
//
//  Created by Amy on 16/7/8.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

let kUSAState   = "usastates"
let kCountry    = "countries"
let kUSACode    = "US"
let kSystemDate = "date"

class SSTCountryData: BaseModel {
    
    var systemDate: String?
    var groups = [SSTCountryGroup]()
    var USAInfo = SSTCountry()
    
    override init() {
        super.init()
        
        if let data = FileOP.unarchive(kCountryFileName) {
            self.refreshData(validDictionary(data))
        }
    }

    required init?(map: Map) {
        super.init(map: map)
    }
    
    func refreshData(_ data: Dictionary<String, Any>) {
        var tmpGroups = [SSTCountryGroup]()
        
        var countries = [SSTCountry]()
        for tmpCountry in validArray(data[kCountry]) {
            if let country = SSTCountry(JSON: validDictionary(tmpCountry)) {
                if country.code == kUSACode {
                    var states = [SSTState]()
                    for tmpState in validArray(data[kUSAState]){
                        if let state = SSTState(JSON: validDictionary(tmpState)) {
                            states.append(state)
                        }
                    }
                    country.states = states
                    USAInfo = country
                }
                countries.append(country)
            }
        }
        countries.sort(by: { (c1, c2) -> Bool in
            validString(c1.name) < validString(c2.name)
        })
        for country in countries {
            let firstLetter = country.name?.sub(start: 0, end: 0).capitalized
            if firstLetter != tmpGroups.last?.countries.last?.name?.sub(start: 0, end: 0).capitalized {
                let group = SSTCountryGroup()
                group.name = firstLetter
                tmpGroups.append(group)
            }
            tmpGroups.last?.countries.append(country)
        }
        
        self.groups = tmpGroups
        self.systemDate = validString(data[kSystemDate])
        
        self.delegate?.refreshUI(self)
    }
    
    func getCountry(_ callback: @escaping RequestCallBack) {
        var paraDateString = validString(self.systemDate)
        if paraDateString == "" || self.groups.count <= 0 {
            paraDateString = "0"
        }
        biz.getCountryAndState(paraDateString) { (data, error) in
            if error == nil, let tmpData = data {
                if !validArray(validDictionary(data)[kCountry]).isEmpty {
                    self.refreshData(validDictionary(data))
                    FileOP.archive(kCountryFileName, object: tmpData)
                }
                callback(self, nil)
            } else {
                callback(nil, error)
            }
        }
    }
}
