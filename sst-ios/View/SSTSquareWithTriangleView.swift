//
//  SSTWarehousesForSelectingView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/10/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

class SSTSquareWithTriangleView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let path = getCustomLayer(showView: self)
        
        path.lineWidth = 1
        UIColor.white.setFill()
        UIColor.darkGray.setStroke()
        path.fill()
        path.stroke()
        
        let tPath = UIBezierPath()
        tPath.lineWidth = 1
        let point1 = CGPoint(x: kTriangleLeftSpace + 0.7, y: kTriangleHeight)
        let point2 = CGPoint(x: kTriangleLeftSpace + 19.3, y: kTriangleHeight)
        tPath.move(to: point1)
        tPath.addLine(to: point2)
        tPath.close()
        UIColor.white.setStroke()
        tPath.stroke()
    }
    
    func getCustomLayer(showView: UIView) -> UIBezierPath {
        
        let viewWidth = CGFloat(showView.frame.width)
        let viewHeight = CGFloat(showView.frame.height)
        
        let squarePath = UIBezierPath(roundedRect: CGRect(x:0, y: kTriangleHeight, width: viewWidth, height: viewHeight - kTriangleHeight), cornerRadius: 5)
        
        let point1 = CGPoint(x: kTriangleLeftSpace, y: kTriangleHeight)
        let point2 = CGPoint(x: kTriangleLeftSpace + 10, y: 0)
        let point3 = CGPoint(x: kTriangleLeftSpace + 20, y: kTriangleHeight)
        
        let path = UIBezierPath()
        path.move(to: point1)
        path.addLine(to: point2)
        path.addLine(to: point3)
        path.close()
        
        squarePath.append(path)
        squarePath.addClip()
        squarePath.close()
        
        return squarePath
    }

}
