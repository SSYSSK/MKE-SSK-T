//
//  SSTHomeDealsCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 7/24/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kCVCellId = "CVCellId"

class SSTHomeDealsCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var seeAllClick: (() -> Void)?
    var itemClick: ((_ item: AnyObject) -> Void)?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.register(initNib("\(SSTCVCell.classForCoder())"), forCellWithReuseIdentifier: kCVCellId)
    }

    @IBAction func clickedMoreButton(_ sender: Any) {
        seeAllClick?()
    }
    
    var items: [SSTItem]! {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: -- UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return validInt(items?.count)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCVCellId, for: indexPath) as! SSTCVCell
        let itemV = loadNib("\(SSTHomeDailyDealsItemV.classForCoder())") as! SSTHomeDailyDealsItemV
        itemV.frame = CGRect(x: 0, y: -cell.y, width: kHomeDailyDealsCellWidth, height: kHomeDailyDealsCellHeight)
        if let tItem = items.validObjectAtIndex(indexPath.row) as? SSTItem {
            itemV.item = tItem
        }
        cell.addSubview(itemV)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kHomeDailyDealsCellWidth, height: collectionView.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let itm = items.validObjectAtIndex(indexPath.row) {
            itemClick?(itm)
        }
    }
}
