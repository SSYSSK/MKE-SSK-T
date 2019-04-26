//
//  SSTApplyCod.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/25.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kApplyTAXDueTime = "dueTime"

let kApplycodfiles = "applycodfiles"
let kApplycod     = "applycod"
let kApplyStatu  = "status"
let kApplyDenyreason  = "denyreason"
let kApplyCreateDate  = "createDate"
let kApplyTaxFreeHasNew  = "taxFreeHasNew"
let kApplyCodFreeHasNew  = "codHasNew"
let kApplyCodHasNew  = "codHasNew"

let kApplyTaxFreefiles = "freetaxapplyfiles"
let kApplyTaxFree     = "freetaxapply"

class SSTApplyCod: BaseModel {

    
    var applyid: Int?
    var status: Int?
    var denyreason: String!

    var applyCodFiles = [SSTApplyCodFile]()
    
    var dueTime: Date?
    
    var taxFreeHasNew: Int!
    var codHasNew: Int!

    fileprivate var liscenceCodFile = SSTApplyCodFile()

    fileprivate var idCodFile = SSTApplyCodFile()

    var bizLiscenceCODFile: SSTApplyCodFile? {
        get {
            for file in applyCodFiles {
                if file.filetitle == kBusinessLicense {
                    return file
                }
            }
            return nil
        }
    }
    
    var bizIDCODFile: SSTApplyCodFile? {
        get {
            for file in applyCodFiles {
                if file.filetitle == kID {
                    return file
                }
            }
            return nil
        }
    }
    
    func addLiscenceCODFile() {
        if bizLiscenceCODFile == nil {
            let codFile = SSTApplyCodFile()
            codFile.filetitle = kBusinessLicense
            self.applyCodFiles.append(codFile)
        }else {
            
        }
    }
    
    func addIDCODFile() {
        if bizIDCODFile == nil {
            let codFile = SSTApplyCodFile()
            codFile.filetitle = kID
            self.applyCodFiles.append(codFile)
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
        
        liscenceCodFile = SSTApplyCodFile()
        idCodFile = SSTApplyCodFile()
        
        liscenceCodFile.imageType = .businessImage
        idCodFile.imageType = .idImage
        
        applyid = nil
        
        applyid          <- map["\(kApplycod).\(kApplyid)"]
        status           <- map["\(kApplycod).\(kApplyStatu)"]
        denyreason       <- map["\(kApplycod).\(kApplyDenyreason)"]
        dueTime           <- (map["\(kApplyTAXDueTime)"], transformStringToDate)
        
        taxFreeHasNew          <- map["\(kApplyTaxFreeHasNew)"]
        
        codHasNew          <- map["\(kApplyCodHasNew)"]
        
        
        if applyid == nil {
            applyid          <- map["\(kApplyTaxFree).\(kApplyid)"]
            status           <- map["\(kApplyTaxFree).\(kApplyStatu)"]
            denyreason       <- map["\(kApplyTaxFree).\(kApplyDenyreason)"]
            dueTime          <- (map["\(kApplyTAXDueTime)"], transformStringToDate)
        }
        
        if status == nil {
            status = -1
        }
        if applyid == nil {
            applyid = -1
        }
        
        if taxFreeHasNew == nil {
            taxFreeHasNew = -1
        }
        
        if codHasNew == nil {
            codHasNew = -1
        }
        
        self.applyCodFiles.removeAll()
        
        self.setFilepaths(validNSArray(map.JSON[kApplycodfiles]))
        
        if applyCodFiles.count == 0 {
            self.setFilepaths(validNSArray(map.JSON[kApplyTaxFreefiles]))
        }
        applyCodFiles.insert(idCodFile, at: 0)
        applyCodFiles.insert(liscenceCodFile, at: 0)
        
    }
    
    func setFilepaths(_ arr: NSArray) {
        
        for fileDict in arr {
            if let applyCodFile = SSTApplyCodFile(JSON: validDictionary(fileDict)) {
                
                if applyCodFile.filetitle == kBusinessLicense {
                    liscenceCodFile = applyCodFile
                    liscenceCodFile.imageType = .businessImage
                    idCodFile.image = nil
                }else if applyCodFile.filetitle == kID {
                    idCodFile = applyCodFile
                    idCodFile.imageType = .idImage
                    idCodFile.image = nil
                }else{
                    applyCodFile.imageType = .otherImage
                    applyCodFiles.append(applyCodFile)
                }
                
            }
        }
    }
    
    func update(_ data: Dictionary<String,AnyObject>) {
        mapping(map: Map(mappingType: .fromJSON, JSON: data))
        self.delegate?.refreshUI(self)
    }
    
    // 获取cod
    func getApplyCod() {
        biz.getAppCOD() { (data, error) in
            if data != nil {
                self.update(validDictionary(data))
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    // 获取免税申请
    func getApplyTaxFree() {
        
        biz.getApplyTaxFree() { (data, error) in
            if data != nil {
                self.update(validDictionary(data))
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    // 获取cod tax status
    func getApplyCodAndTaxFreeStatus(){
        biz.getApplyCodAndTaxFreeStatus() { (data, error) in
            if data != nil {
                self.update(validDictionary(data))
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    func uploadCODImage(_ image:UIImage, title:String, callback: @escaping RequestCallBack) {
        biz.applyCOD(image , title: title) { (data, error) in
            callback(data,error)
        }
    }
    
    func deleteCODImageById(_ fileId:Int, callback: @escaping RequestCallBack) {
        biz.deleteCODImageById(fileId) { (data, error) in
            callback(data,error)
        }
    }

    func updateCODNameById(_ fileId:Int, title:String,  callback: @escaping RequestCallBack) {
        biz.updateCODTitleById(fileId, title: title) { (data, error) in
            callback(data,error)
        }
    }

    func uploadTAXImage(_ image:UIImage, title:String, callback: @escaping RequestCallBack) {
        biz.applyTAX(image , title: title) { (data, error) in
            callback(data,error)
        }
    }
    
    func deleteTAXImageById(_ fileId:Int, callback: @escaping RequestCallBack) {
        biz.deleteTAXImageById(fileId) { (data, error) in
            callback(data,error)
        }
    }
    
    func updateTAXNameById(_ fileId:Int, title:String,  callback: @escaping RequestCallBack) {
        if validString(title) == "" {
            biz.updateTAXTitleById(fileId, title: "*") { (data, error) in
                callback(data,error)
            }
        }else {
            biz.updateTAXTitleById(fileId, title: title) { (data, error) in
                callback(data,error)
            }
        }
    }

}
