//
//  SSTContactMsg.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import ObjectMapper

class SSTContactRecord: BaseModel {
    
    var id: String?
    var imgUrl: String?
    var title: String?
    var status: Int?
    var msgCnt: Int?
    var dateCreated: Date?
    
    var replies = [SSTContactReply]()
    
    var statusText: String {
        get {
            if status == nil {
                return ""
            } else if status == 0 {
                return "In Progress"
            } else if status == 1 {
                return "Done"
            }
            return ""
        }
    }
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        id              <- (map["questionId"],transformIntToString)
        imgUrl          <- map["originalPicture"]
        title           <- map["question"]
        status          <- map["status"]
        msgCnt          <- map["unreadNum"]
        dateCreated     <- (map["createDate"],transformStringToDate)
    }
    
    func setReplies(replyArray: Array<Any>) {
        var tReplies = [SSTContactReply]()
        for reply in replyArray {
            if let rply = SSTContactReply(JSON: validDictionary(reply)) {
                tReplies.append(rply)
            }
        }
        self.replies = tReplies
    }
    
    func fetchContactRecordReplies(id: String, callback: RequestCallBack? = nil) {
        biz.getContactRecordReplies(id: id) { (data, error) in
            if nil == error {
                self.setReplies(replyArray: validArray(data))
                callback?(self, nil)
                self.delegate?.refreshUI(self)
            } else {
                callback?(nil, error)
                self.delegate?.refreshUI(error)
            }
        }
    }
    
    func addReply(msg: String, callback: @escaping RequestCallBack) {
        biz.addContactReply(questionId: validString(self.id), msg: msg) { data, error in
            self.setReplies(replyArray: validArray(data))
            callback(data, error)
            self.delegate?.refreshUI(self)
        }
    }
    
    func addReplyImage(image: UIImage, fileName: String, callback: @escaping RequestCallBack) {
        biz.addContactReplyImage(questionId: validString(self.id), image: image, fileName: fileName) { data, error in
            self.setReplies(replyArray: validArray(data))
            callback(data, error)
            self.delegate?.refreshUI(self)
        }
    }
    
    func addRateAndSuggestion(score: Int, suggestion: String, callback: @escaping RequestCallBack) {
        biz.addRateAndSuggestion(questionId: validString(self.id), score: score, suggestion: suggestion) { data, error in
            callback(data, error)
        }
    }

}
