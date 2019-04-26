//
//  SSTImageViewVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/26/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kImageViewReuseId = "SSTImageViewCell"

class SSTImageViewVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var indexPath: IndexPath!
    var imgUrls: [String]!
    
    var deletable: Bool = false
    var imgs: [UIImage]! {
        didSet {
            collectionView.reloadData()
        }
    }
    var disappeard: ((_ imgs: [UIImage]) -> Void)?
    
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: XTPhotoLayout())

    override func viewDidLoad() {
        super.viewDidLoad()
    
        collectionView.frame = view.bounds
        collectionView.register(SSTImageViewCell.classForCoder(), forCellWithReuseIdentifier: kImageViewReuseId)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.scrollToItem(at: indexPath, at: .left, animated: false)
        
        if deletable {
            let deleteButton = UIButton(frame: CGRect(x: kScreenWidth - 90, y: 35, width: 70, height: 30))
            deleteButton.setTitle("Delete", for: UIControlState.normal)
            deleteButton.backgroundColor = RGBA(112, g: 111, b: 252, a: 1)
            deleteButton.layer.cornerRadius = 3
            deleteButton.addTarget(self, action: #selector(SSTImageViewVC.clickedDeleteButton(_:)), for: UIControlEvents.touchUpInside)
            self.view.addSubview(deleteButton)
            self.view.bringSubview(toFront: deleteButton)
        }
    }
    
    func vcDisappeard() {
        disappeard?(imgs)
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func clickedDeleteButton(_ tap: UITapGestureRecognizer) {
        let indClicked = validInt( (collectionView.contentOffset.x + 10) / kScreenWidth)
        if imgs != nil {
            imgs.remove(at: indClicked)
            if imgs.count == 0 {
                vcDisappeard()
            }
        } else {
            imgUrls.remove(at: indClicked)
        }
        collectionView.reloadData()
    }
    
    // MARK: -- UICollectionViewDataSource, UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imgs != nil {
            return imgs.count
        } else {
            return imgUrls.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kImageViewReuseId, for: indexPath) as! SSTImageViewCell
        
        if imgs != nil {
            cell.image = imgs[indexPath.row]
        } else {
            cell.imageUrl = imgUrls[indexPath.row]
        }
        
        cell.itemClick = { [weak self] item in
            self?.vcDisappeard()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        vcDisappeard()
    }

}
