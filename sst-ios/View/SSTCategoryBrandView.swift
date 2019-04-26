//
//  CategoryBrandView.swift
//  sst-ios
//
//  Created by MuChao Ke on 17/2/27.
//  Copyright © 2017年 ios. All rights reserved.
//

import UIKit



class SSTCategoryBrandView: UIView {

    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var brandButton: UIButton!
    
    
    var clickedCategoryBrandView:((_ categoryBrandViewEnum: CategoryOrBrand) ->Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
      
    }
    
    @IBAction func brandEvent(_ sender: Any) {
        brandButton.setTitleColor(RGBA(111, g: 116, b: 244, a: 1), for: UIControlState.normal)
        categoryButton.setTitleColor(RGBA(73, g: 73, b: 73, a: 1), for: UIControlState.normal)
        if let block = clickedCategoryBrandView {
        
            
            UIView.animate(withDuration: 0.1) {
                self.lineView.center = CGPoint(x: kScreenWidth/4*3, y: 40)
            }
            block(CategoryOrBrand.brand)
        }
    }
    
    
    @IBAction func categoryEvent(_ sender: Any) {
        brandButton.setTitleColor(RGBA(73, g: 73, b: 73, a: 1), for: UIControlState.normal)
        categoryButton.setTitleColor(RGBA(111, g: 116, b: 244, a: 1), for: UIControlState.normal)
        if let block = clickedCategoryBrandView {
            UIView.animate(withDuration: 0.1) {
                self.lineView.center = CGPoint(x: kScreenWidth/4, y: 40)
                
            }
            block(CategoryOrBrand.category)
        }
    }
}
