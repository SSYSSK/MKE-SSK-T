//
//  SSTArticle.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/9/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

let kArticleId      = "articleid"
let kArticleTitle   = "articletitle"
let kArticleContent = "articletext"

class SSTArticle: BaseModel {
    
    var id: String!
    var title: String!
    var content: String?
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id          <- map["\(kArticleId)"]
        title       <- map["\(kArticleTitle)"]
        content     <- map["\(kArticleContent)"]
    }
    
    static func fetchArticle(id: String, callback: @escaping RequestCallBack) {
        biz.getArticle(id: id) { data, error in
            if error == nil {
                if let article = SSTArticle(JSON: validDictionary(data)) {
                    callback(article, error)
                }
            } else {
                callback(data, error)
            }
        }
    }
}
