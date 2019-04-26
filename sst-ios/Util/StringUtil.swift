 //
//  StringUtil.swift
//  sst-ios-po
//
//  Created by Zal Zhang on 12/28/16.
//  Copyright © 2016 po. All rights reserved.
//

import UIKit

extension String {
    
    func matchRegex(pattern: String) -> Bool {
        if self.trim().count == 0 {
            return false
        }
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [pattern])
        return predicate.evaluate(with: self.trim())
    }
    
    var isValidEmail: Bool {
        return matchRegex(pattern:"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}")
    }
    
    var isValidPassword: Bool {
        return matchRegex(pattern:"[A-Z0-9a-z._%+-]{1,20}")
    }
    
    var isValidCharacter: Bool {
        return matchRegex(pattern:"[A-Za-z]")
    }
    
    var isValidMoney: Bool {
        return matchRegex(pattern: "^([1-9]\\d*|0)(\\.\\d{0,2})?$")
    }

    var isTwoDecimal: Bool {
        return matchRegex(pattern: "^[0-9]+(.[0-9]{2})?$")
    }
    
    var URL: NSURL? {
        return NSURL(string: self)
    }
    
    var Base64: String {
        if let utf8EncodeData = self.data(using: String.Encoding.utf8, allowLossyConversion: true) {
            return utf8EncodeData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        }
        return ""
    }

    var URLEncoded: String {
        return validString(self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlPathAllowed))
    }
    
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
    
    var isValidInteger: Bool {
        return matchRegex(pattern: "^[0-9]\\d*$")
    }
    
    var isValidZipForUS: Bool {
        return matchRegex(pattern: "[0-9]{5}")
    }
    
    var isValidZipForCanada: Bool {
        return self.replacingOccurrences(of: " ", with: "").matchRegex(pattern: "[0-9a-zA-Z]{6}")
    }
    
    var isValidNaturalNumber: Bool {
        return matchRegex(pattern: "^[0-9]*$")
    }
    
    var isValidPositiveInteger: Bool {
        return matchRegex(pattern: "^[1-9]\\d*$")
    }
    
    var isValidZipCode:Bool {
        return matchRegex(pattern: "[1-9]\\d{4}")
    }
    
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func strikeThrough() -> NSMutableAttributedString {
        let attributedStr = NSMutableAttributedString(string: self)
        attributedStr.addAttributes([NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue], range: NSMakeRange(0, validInt(self.count)))
        return attributedStr
    }
    
    func toAttributedString(font: UIFont = UIFont.systemFont(ofSize: 13)) -> NSAttributedString {
        var attributedString = NSMutableAttributedString()
        if let stringData = "<div>\(self)</div>".replaceInvisibleCharatersWithSapce().data(using: String.Encoding.utf8) {
            let tAttr = stringData.toAttributedString()
            attributedString = tAttr.mutableCopy() as! NSMutableAttributedString
            attributedString.addAttributes([NSAttributedStringKey.font: font], range: NSMakeRange(0 , attributedString.length))
        }
        return attributedString
    }
    
    func sub(start: Int, end: Int) -> String {
        guard start >= 0 && start < self.count && start <= end else { return "" }
        let startIndex = self.index(self.startIndex, offsetBy: start)
        let endIndex = self.index(self.startIndex, offsetBy: (end < self.count) ? end : self.count - 1 )
        return String(self[startIndex...endIndex])
    }
    
    func escapeHtml() -> String {
        var vStr = self
        
        for _ in 0 ... 10000 {
            if vStr.contains("<") && vStr.contains(">") {
                if let low = vStr.range(of: "<")?.lowerBound, let upper = vStr.range(of: ">")?.upperBound {
                    vStr.replaceSubrange(Range(low ..< upper), with: "")
                }
            } else {
                break
            }
        }
        return vStr
    }
    
    func escapeHtmlP() -> String {
        return self.replacingOccurrences(of: "<p>", with: "").replacingOccurrences(of: "<P>", with: "").replacingOccurrences(of: "</p>".replacingOccurrences(of: "</P>", with: ""), with: "")
    }
    
    func heightByWidthAndNewLine(font: NSInteger, width: CGFloat) -> CGFloat {
        var rHeight: CGFloat = 0
        let stirngs = self.components(separatedBy: "\n")
        for str in stirngs {
            rHeight += str.sizeByWidth(font: font, width: width).height + CGFloat(font)
        }
        return rHeight
    }
    
    func heightByWidth(font: NSInteger, width: CGFloat) -> CGFloat {
        return sizeByWidth(font: font, width: width).height
    }
    
    func sizeByWidth(font: NSInteger, width: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        return sizeByFont(font: UIFont.systemFont(ofSize: CGFloat(font)), maxWidth: width)
    }
    
    func sizeByFont(font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        let attributes = [NSAttributedStringKey.font:font, NSAttributedStringKey.paragraphStyle:paragraphStyle.copy()]
        let rect = self.boundingRect(with: size, options:.usesLineFragmentOrigin, attributes: attributes, context:nil)
        return rect.size
    }
    
    func toUrl() -> String {
        return self.replacingOccurrences(of: " ", with: "%20")
    }
    
    func toDictionary() -> Dictionary<String,AnyObject>? {
        if let tData = self.data(using: String.Encoding.unicode, allowLossyConversion: true) {
            let dict = try? JSONSerialization.jsonObject(with: tData, options:JSONSerialization.ReadingOptions.allowFragments)
            return dict as? Dictionary<String, AnyObject>
        }
        return nil
    }
    
    func replaceInvisibleCharatersWithSapce() -> String {
        let rString: NSMutableString = NSMutableString(string: self)
        let regex = try! NSRegularExpression(pattern: "(\\s){1,}", options: [])
        regex.replaceMatches(in: rString, options: [], range: NSMakeRange(0, rString.length), withTemplate: " ")
        return rString as String
    }
}

extension String: URLStringConvertible {
    public var URLString: String {
        return self
    }
}

extension NSString: URLStringConvertible {
    public var URLString: String {
        get {
            return self as String
        }
    }
}

extension NSAttributedString {
    func addLineSpaceTextAligment(space: CGFloat, textAlignment: NSTextAlignment) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = space
        paragraphStyle.alignment = textAlignment
        
        let rAttributedString = self.mutableCopy() as! NSMutableAttributedString
        rAttributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, self.length))
        return rAttributedString
    }
    
    func addColor(color: UIColor) -> NSAttributedString {
        let rAttributedString = self.mutableCopy() as! NSMutableAttributedString
        rAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSMakeRange(0, self.length))
        return rAttributedString
    }
    
    func addFontSize(size: CGFloat) -> NSAttributedString {
        let rAttributedString = self.mutableCopy() as! NSMutableAttributedString
        rAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: size), range: NSMakeRange(0, self.length))
        return rAttributedString
    }
    
    func addBoldFontSize(size: CGFloat) -> NSAttributedString {
        let rAttributedString = self.mutableCopy() as! NSMutableAttributedString
        rAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.boldSystemFont(ofSize: size), range: NSMakeRange(0, self.length))
        return rAttributedString
    }
    
    func strikeThrough(_ start: Int = 0, _ end: Int? = nil) -> NSAttributedString {
        let rAttributedString = self.mutableCopy() as! NSMutableAttributedString
        var tEnd = self.length
        if end != nil {
            tEnd = validInt(end)
        }
        rAttributedString.addAttributes([NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue], range: NSMakeRange(start, tEnd))
        return rAttributedString
    }
    
    func sizeByFont(font: UIFont, maxWidth: CGFloat = CGFloat.greatestFiniteMagnitude) -> CGSize {
        let size = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, context: nil)
        return rect.size
    }
}
