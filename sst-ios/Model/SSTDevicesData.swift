//
//  SSTDevicesData.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

class SSTDevicesData: BaseModel {
    var devicess = [SSTDevices]()
    
    func getDevices(seriesId: Int){
        var infos = [SSTDevices]()
        biz.getDevices(seriesId: seriesId) { (data, error) in
            if error == nil {
                for item in validNSArray(data) {
                    if let series = SSTDevices(JSON: validDictionary(item)) {
                        infos.append(series)
                    }
                }
                self.devicess = infos
                self.delegate?.refreshUI(self)
            }else {
                self.delegate?.refreshUI(error)
            }
        }
    }
}
