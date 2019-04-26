//
//  SSTSeriesData.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTSeriesData: BaseModel {
    
    var seriess = [SSTSeries]()
    
    func getSeriess(brandId: Int) {
        var infos = [SSTSeries]()
        biz.getSeriess(brandId: brandId) { (data, error) in
            if error == nil {
                for item in validNSArray(data) {
                    if let series = SSTSeries(JSON: validDictionary(item)) {
                        infos.append(series)
                    }
                }
                self.seriess = infos
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }
}
