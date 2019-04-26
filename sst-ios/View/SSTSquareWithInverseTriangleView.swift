//
//  SSTSquareWithInverseTriangleView.swift
//  sst-ios
//
//  Created by Zal Zhang on 1/10/18.
//  Copyright © 2018 ios. All rights reserved.
//

import UIKit

let kTriangleLeftSpace: CGFloat = 100         // 所占的宽度,整个view所占的宽度不会变,已经被制定,所以这个宽度会占用整个view的宽度,
let kTriangleHeight: CGFloat = 15            // 距离顶部的距离

class SSTSquareWithInverseTriangleView: UIView {
    
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
        let point1 = CGPoint(x: kTriangleLeftSpace + 0.7, y: self.height - kTriangleHeight)
        let point2 = CGPoint(x: kTriangleLeftSpace + 19.3, y: self.height - kTriangleHeight)
        tPath.move(to: point1)
        tPath.addLine(to: point2)
        tPath.close()
        UIColor.white.setStroke()
        tPath.fill()
        tPath.stroke()
    }
    
    func getCustomLayer(showView: UIView) -> UIBezierPath {
        
        let viewWidth = CGFloat(showView.frame.width)
        let viewHeight = CGFloat(showView.frame.height)
        
        let squarePath = UIBezierPath(roundedRect: CGRect(x:0, y: 0, width: viewWidth, height: viewHeight - kTriangleHeight), cornerRadius: 5)
        
        let point1 = CGPoint(x: kTriangleLeftSpace, y: viewHeight - kTriangleHeight)
        let point2 = CGPoint(x: kTriangleLeftSpace + 10, y: viewHeight)
        let point3 = CGPoint(x: kTriangleLeftSpace + 20, y: viewHeight - kTriangleHeight)
        
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
