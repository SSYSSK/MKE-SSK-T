//
//  SSTSearchData.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/15/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

let kSearchSuggestions    = "suggestions"
let kSearchNumFound       = "numFound"
let kSearchStart          = "start"
let kSearchDocs           = "docs"
let kSearchFacets         = "facets"

class SSTSearchData: BaseModel {
    
    var suggestions = [String]()
    var start = 0
    var numFound = 0
    
    override init() {
        super.init()
    }
    
    init(searchData: SSTSearchData) {
        super.init()
        
        self.suggestions = searchData.suggestions
        self.start = searchData.start
        self.numFound = searchData.numFound
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
}
