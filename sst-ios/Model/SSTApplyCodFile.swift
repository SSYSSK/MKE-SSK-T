//
//  SSTApplyCodFile.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/19.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import ObjectMapper

let kApplyid     = "applyid"
let kFiletitle   = "filetitle"
let kFilepath    = "filepath"
let kDelflag     = "delflag"
let kFileid      = "fileid"

enum CODImageType {
    case addImage
    case businessImage
    case idImage
    case otherImage
}

class SSTApplyCodFile: BaseModel {
    
    
    var applyid: Int!
    var filetitle: String = ""
    var filepath: String = ""
    var delflag: Int = -1
    var fileid: Int!
    
    var image : UIImage?
    
    var imageType:CODImageType = .otherImage
    
    override init() {
        super.init()
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        applyid          <- map[kApplyid]
        filetitle        <- map[kFiletitle]
        filepath         <- map[kFilepath]
        delflag          <- map[kDelflag]
        fileid           <- map[kFileid]

        if applyid == nil {
            applyid = -1
        }
        
        let imgV = UIImageView()
        imgV.setImage(fileUrl: filepath, placeholder: nil) { (data, error) in
            if error == nil && data != nil {
                self.image = data as? UIImage
            }
        }
    }
}
