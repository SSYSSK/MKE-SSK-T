//
//  SSTImageViewCell.swift
//  sst-ios
//
//  Created by Zal Zhang on 6/26/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

class SSTImageViewCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var itemClick: ((_ obj: AnyObject) -> Void)?
    
    fileprivate var scrollView: UIScrollView = UIScrollView()
    fileprivate var imageView: UIImageView = UIImageView()
    fileprivate var lastWidth: CGFloat = kScreenWidth
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
        
        imageView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        imageView.contentMode = .scaleAspectFit
        
        imageView.isUserInteractionEnabled = true
        imageView.isMultipleTouchEnabled = true
//        let pinRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(doForPinchRecognizer))
//        imageView.addGestureRecognizer(pinRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doForTapRecognizer))
        tapRecognizer.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(tapRecognizer)
        
        let singleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doForSingleTapRecognizer))
        singleTapRecognizer.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(singleTapRecognizer)
        
        scrollView.addSubview(imageView)
        self.addSubview(scrollView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var imageUrl: String? {
        didSet {
            SSTProgressHUD.show(view: self)
            self.imageView.setImage(fileUrl: validString(imageUrl), placeholder: kItemDetailPlaceholderImageName) { data, error in
                SSTProgressHUD.dismiss(view: self)
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    @objc func doForSingleTapRecognizer(recognizer: UITapGestureRecognizer) {
        itemClick?(recognizer)
    }
    
    @objc func doForTapRecognizer(recognizer: UITapGestureRecognizer) {
        if scrollView.zoomScale <= 1 {
            scrollView.zoomScale = 2
        } else {
            scrollView.zoomScale = 1
        }
//        if lastWidth <= kScreenWidth + CGFloat(kOneInMillion) {
//            scaleImage(scale: 2)
//        } else {
//            scaleImage(scale: 0.5)
//        }
    }
    
    func doForPinchRecognizer(recognizer: UIPinchGestureRecognizer) {
        scaleImage(scale: recognizer.scale)
    }
    
    func scaleImage(scale: CGFloat) {
        var tWdith = lastWidth * scale
        if tWdith > kScreenWidth * 5 {
            tWdith = kScreenWidth * 5
        } else if tWdith < kScreenWidth * 1 {
            tWdith = kScreenWidth * 1
        }
        lastWidth = tWdith
        self.imageView.setImage(fileUrl: validString(imageUrl), placeholder: kItemDetailPlaceholderImageName) { data, error in
            self.imageView.image = self.imageView.image?.af_imageScaled(to: CGSize(width: tWdith, height: tWdith))
        }
    }
}
