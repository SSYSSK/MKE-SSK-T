//
//  SSTFeedback.swift
//  sst-ios
//
//  Created by Amy on 2016/11/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
let kResult = "result"

class SSTFeedbackData: BaseModel {
    
    var contents = [SSTFeedback]()
    var title: String!
    var url: String!
    var total = 0
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }

    func update(_ array: Array<Any>) {
        var contents = [SSTFeedback]()
        
        if array.count > 0 {
            for item in array {
                if let content = SSTFeedback(JSON: validDictionary(item)) {
                    contents.append(content)
                }
            }
        }
        self.contents = contents
    }
    
    func fetchData(_ size: Int) {
        biz.getSolutions(size) { (data, error) in
            if error == nil {
                self.total = validInt(validDictionary(data)[kTotal])
                self.update(validArray(validDictionary(data)[kResult]))
                self.delegate?.refreshUI(self)
//                callback(data: self, error: nil)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    static func uploadFeedback(_ content: String, callback: @escaping RequestCallBack) {
        biz.uploadFeedback(content) { (data, error) in
            if error == nil {
                callback(data, nil)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
}
