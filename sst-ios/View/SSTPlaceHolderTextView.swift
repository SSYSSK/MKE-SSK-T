//
//  SSTPlaceHolderTextView.swift
//  sst-ios
//
//  Created by Amy on 2016/11/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTPlaceHolderTextView: UITextView {

    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray
    @IBInspectable var placeholderTexts: String = ""
    
    override var font: UIFont? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    fileprivate func setUp() {
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(SSTPlaceHolderTextView.textChanged(_:)),
                                                         name: NSNotification.Name.UITextViewTextDidChange, object: self)
    }
    
    @objc func textChanged(_ notification: Notification) {
        setNeedsDisplay()
    }
    
    func placeholderRectForBounds(_ bounds: CGRect) -> CGRect {
        var x = contentInset.left + 4.0
        var y = contentInset.top  + 9.0
        let w = frame.size.width - contentInset.left - contentInset.right - 16.0
        let h = frame.size.height - contentInset.top - contentInset.bottom - 16.0
        
        if let style = self.typingAttributes[NSAttributedStringKey.paragraphStyle.rawValue] as? NSParagraphStyle {
            x += style.headIndent
            y += style.firstLineHeadIndent
        }
        return CGRect(x: x, y: y, width: w, height: h)
    }
    
    override func draw(_ rect: CGRect) {
        if validString(text).isEmpty && placeholderTexts.isNotEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            let attributes: [ NSAttributedStringKey: AnyObject ] = [
                NSAttributedStringKey.font : ((font == nil) ? UIFont.systemFont(ofSize: 13) : font!) ,
                NSAttributedStringKey.foregroundColor : placeholderColor,
                NSAttributedStringKey.paragraphStyle  : paragraphStyle
            ]
            
            placeholderTexts.draw(in: placeholderRectForBounds(bounds), withAttributes: attributes)
        }
        super.draw(rect)
    }
}
