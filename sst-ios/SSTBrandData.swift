//
//  SSTBrandData.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/16.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit

let kBrands         = "brands"
let kBrandsInHot    = "brandsInHot"

let kIndexLetters   = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]

class SSTBrandData: BaseModel {
    
    var brands = [SSTBrand]()
    var brandsInHot = [SSTBrand]()
    
    var brandGroups = [[SSTBrand]]()
    
    func getBrands() {
        biz.getBrands { (data, error) in
            if error == nil {
                var infos = [SSTBrand]()
                for item in validArray(validDictionary(data)[kBrands]) {
                    if let brand = SSTBrand(JSON: validDictionary(item)) {
                        infos.append(brand)
                    }
                }
                self.brands = infos
                
                self.brands.sort(by: { (brandA, brandB) -> Bool in
                    return brandA.brandName.lowercased() < brandB.brandName.lowercased()
                })
                
                var hotInfos = [SSTBrand]()
                for item in validArray(validDictionary(data)[kBrandsInHot]) {
                    if let brand = SSTBrand(JSON: validDictionary(item)) {
                        hotInfos.append(brand)
                    }
                }
                self.brandsInHot = hotInfos
                
                self.groupBrands()
                
                self.delegate?.refreshUI(self)
            } else {
                self.delegate?.refreshUI(error)
            }
        }
    }
    
    func groupBrands() {
        var tGroups = [[SSTBrand]]()
        
        var tOtherGroup = [SSTBrand]()
        
        for letter in kIndexLetters {
            var tGroup = [SSTBrand]()
            for brand in self.brands {
                let firstLetter = brand.brandName.sub(start: 0, end: 0)
                if firstLetter.uppercased() == letter.uppercased() {
                    tGroup.append(brand)
                } else if firstLetter.uppercased() < "A" || firstLetter.uppercased() > "Z" {
                    tOtherGroup.append(brand)
                }
            }
            if tGroup.count > 0 {
                tGroups.append(tGroup)
            }
        }
        
        if tOtherGroup.count > 0 {
            tGroups.append(tOtherGroup)
        }
        
        self.brandGroups = tGroups
    }
}
