//
//  SSTShippingCompanyData.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/14/16.
//  Copyright © 2016 SST. All rights reserved.
//

import UIKit

class SSTShippingCompanyData: BaseModel {
    
    var shippingCompanies = [SSTShippingCompany]()
    
    func getAllShippingCompany() {
        var infos = [SSTShippingCompany]()
        biz.getAllShippingCompany { (data, error) in
            if error == nil {
                for item in validNSArray(data) {
                    if let tItem = SSTShippingCompany(JSON: validDictionary(item)) {
                        infos.append(tItem)
                    }
                }
                self.shippingCompanies = infos
                self.delegate?.refreshUI("ShippingCompanyList")
            }
        }
    }
    
    func getFreeShippingCompanyInfo() {
        var infos = [SSTShippingCompany]()
        biz.getFreeShippingInfo { (data, error) in
            if error == nil {
                for item in validNSArray(data) {
                    if let tItem = SSTShippingCompany(JSON: validDictionary(item)) {
                        infos.append(tItem)
                    }
                }
                self.shippingCompanies = infos
                self.delegate?.refreshUI("FreeShippingCompany")
            }
        }
    }

}
