//
//  Utils.swift
//  sst-ios-po
//
//  Created by Zal Zhang on 12/26/16.
//  Copyright © 2016 po. All rights reserved.
//

import UIKit
import AlamofireImage.Swift

func loadNib(_ nibName: String) -> AnyObject? {
    return Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)?.first as AnyObject?
}

func initNib(_ nibName: String) -> UINib {
    return UINib(nibName: "\(nibName)", bundle: nil)
}

func loadVC(controllerName: String, storyboardName: String) -> AnyObject {
    let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
    return storyboard.instantiateViewController(withIdentifier: controllerName)
}

func validBool(_ data: Any?) -> Bool {
    if data == nil {
        return false
    } else {
        return data as! Bool
    }
}

func validString(_ data: Any?) -> String {
    if data == nil {
        return ""
    }
    let rString = "\(data!)"
    if rString == "<null>" {
        return ""
    }
    return rString
}

func validDouble(_ data: Any?) -> Double {
    if let rst = (data as AnyObject).doubleValue {
        return rst
    }
    return 0
}

func validCGFloat(_ data: Any?) -> CGFloat {
    return CGFloat(validDouble(data))
}

func validMoney(_ data: Any?) -> Double {   // to cover some currency which . is , like france currency
    if data == nil {
        return 0
    } else {
        return validDouble(validString(data).replacingOccurrences(of: ",", with: "."))
    }
}

func validInt(_ data: Any?) -> Int {
    return Int(validDouble(data))
}

func validInt64(_ data: Any?) -> Int64 {
    if data == nil {
        return 0
    } else {
        return (data as AnyObject).longLongValue
    }
}

func validDate(_ data: Any?) -> Date {
    if let r = data as? Date {
        return r
    }
    return Date()
}

func validNSDictionary(_ data: Any?) -> NSDictionary {
    if let nsDict = data as? NSDictionary {
        return nsDict
    }
    return NSDictionary()
}

func validDictionary(_ data: Any?) -> Dictionary<String,AnyObject> {
    if let dict = data as? Dictionary<String, AnyObject> {
        return dict
    }
    return Dictionary()
}

func validNSArray(_ data: Any?) -> NSArray {
    if let nsArray = data as? NSArray {
        return nsArray
    }
    return NSArray()
}

func validArray(_ data: Any?) -> Array<AnyObject> {
    if let r = data as? Array<AnyObject> {
        return r
    }
    return Array()
}

func isError(_ data: Any?) -> Bool {
    if (data as AnyObject).isKind(of: NSError.classForCoder()) {
        return true
    } else if (data.unsafelyUnwrapped as? Error) != nil {
        return true
    }
    return false
}

extension NSArray {
    func validObjectAtIndex(_ index: Int) -> AnyObject? {
        if index < self.count {
            return object(at: index) as AnyObject?
        } else {
            return nil
        }
    }
}

extension Array {
    func validObjectAtIndex(_ index: Int) -> AnyObject? {
        if index >= 0 && index < self.count {
            return self[index] as AnyObject?
        } else {
            return nil
        }
    }
    func validObjectAtLoopIndex(_ index: Int) -> AnyObject? {
        if self.count == 0 || index >= self.count {
            return nil
        }
        let ind = (index + self.count) % self.count
        if ind >= 0 && ind < self.count {
            return self[ind] as AnyObject?
        } else {
            return nil
        }
    }
}

extension UIImageView {
    func setImage(fileUrl: String, placeholder: String? = nil, callback: RequestCallBack? = nil) {
        var image: UIImage? = nil
        if placeholder != nil {
            image = UIImage(named: placeholder!)
        }
        if fileUrl.isEmpty {
            self.image = image
        } else {
            if var mURL = URL(string: fileUrl) {
                if validString(mURL.scheme) == "" {
                    if let tmpUrl = URL(string: kBaseImageURL + fileUrl) {
                        mURL = tmpUrl
                    }
                }
                self.af_setImage(withURL: mURL, placeholderImage: image, completion: { response in
                    switch response.result {
                    case .success:
                        callback?(response.data, nil)
                    case .failure(let error):
                        callback?(nil, error)
                    }
                })
            }
        }
    }
    func setImageWithImage(fileUrl: String, placeImage: UIImage? = nil) {
        
        if fileUrl.isEmpty {
            self.image = placeImage
        } else {
            if var mURL = URL(string: fileUrl) {
                if validString(mURL.scheme) == "" {
                    mURL = URL(string: kBaseImageURL + fileUrl)!
                }
                self.af_setImage(withURL: mURL, placeholderImage: placeImage)
            }
        }
    }
}

let kDateFormatFromString = "yyyy-MM-dd HH:mm:ss Z" // "EEE MMM dd HH:mm:ss zzz yyyy"
let kDateFormatToString = "MM/dd/yyyy HH:mm"
let kDateMmddyyFormatToString = "MM/dd/yyyy"
let kDateYYYYMMDDFormat = "yyyy-MM-dd"
let kDateFormatYYYYMM = "yyyy-MM"
let kDateFormatHHmmForCA = "HHmm"

extension Date {
    static func formatTime(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormatFromString
        dateFormatter.timeZone = NSTimeZone(abbreviation:"CST") as TimeZone!
        if let date = dateFormatter.date(from: dateString) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
    static func fromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormatFromString
        return dateFormatter.date(from: dateString)
    }
    func format() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormatFromString
        return dateFormatter.string(from: self)
    }
    func formatYYYYMM() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormatYYYYMM
        return dateFormatter.string(from: self)
    }
    func formatHMmmddyyyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormatToString
        return dateFormatter.string(from: self)

    }
    func formatYYYYMMDD() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateYYYYMMDDFormat
        return dateFormatter.string(from: self)
    }
    func formatMMddyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateMmddyyFormatToString
        return dateFormatter.string(from: self)
    }
    func formatHHmmForCA() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = kDateFormatHHmmForCA
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -8 * 60 * 60)
        return dateFormatter.string(from: self)
    }
    func getJsonObject(data: NSData) -> AnyObject? {
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options:JSONSerialization.ReadingOptions.allowFragments) as AnyObject?
        } catch {
            return nil
        }
    }
}

func getUserDefautsData(name: String) -> AnyObject? {
    return UserDefaults.standard.object(forKey: name) as AnyObject?
}

func printDebug(_ items: Any...) {
    #if DEV || QA
        debugPrint(items)
    #endif
}

func showToastOnlyForDEV(_ msg: String, duration: Double = 3.5) {
    #if DEV
        ToastUtil.showToast(msg)
    #endif
}

func presentLoginVC(_ callback: @escaping RequestCallBack) {
    if getTopVC()?.classForCoder == SSTMoreVC.classForCoder() {
        (getTopVC() as? SSTMoreVC)?.isLoginVCShowing = true
    }
    
    let loginNC = loadVC(controllerName: "SSTLoginNC", storyboardName: "Login") as! SSTBaseNC
    let loginVC = loginNC.childViewControllers.first as! SSTLoginAndRegisterVC
    loginVC.relogBlock = { isLogined in
        if isLogined {
            callback(nil, nil)
        } else {
            callback(nil, "")
        }
        (gMainTC?.selectedViewController?.childViewControllers.first as? SSTMoreVC)?.refreshView()
        (gMainTC?.selectedViewController?.childViewControllers.first as? SSTMoreVC)?.refreshProfileCell()
    }
    
    let window = UIApplication.shared.delegate?.window
    window??.rootViewController?.present(loginNC, animated: true, completion: nil)
}

var window: UIWindow {
    get {
        if let tmpW = UIApplication.shared.delegate?.window {
            return tmpW!
        }
        return UIWindow()
    }
}

func getTopControllerView(view: UIView) -> UIView? {
    if let VCWrapperClass = NSClassFromString("UINavigationTransitionView") {
        if validBool(view.superview?.superview?.isKind(of: VCWrapperClass)) {
            return view
        }
    }
    for subV in view.subviews {
        return getTopControllerView(view: subV)
    }
    return nil
}

func getTopWindow() -> UIWindow? {
    let frontToBackWindows = UIApplication.shared.windows.reversed()
    for window in frontToBackWindows {
        if window.windowLevel == UIWindowLevelNormal && window.rootViewController != nil {
            return window
        }
    }
    return nil
}

func getTopVC() -> UIViewController? {
    if let win = getTopWindow() {
        if let vc = getTopControllerView(view: win)?.viewController() {
            if vc.isKind(of: UINavigationController.classForCoder()) {
                return vc.childViewControllers.last
            } else if vc.isKind(of: UIViewController.classForCoder()) {
                return vc
            }
        }
    }
    return nil
}

func getTopView() -> UIView? {
    var tView = getTopVC()?.view
    while tView?.superview != nil {
        tView = tView?.superview
    }
    return tView
}

func getAlertWindow() -> UIWindow? {
    let frontToBackWindows = UIApplication.shared.windows.reversed()
    for window in frontToBackWindows {
        if window.windowLevel == UIWindowLevelAlert {
            return window
        }
    }
    return nil
}

func RGBA(r:CGFloat, g:CGFloat, b:CGFloat, a:CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

func isCanUseCamera() -> Bool {
//    let author = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
//    if (author == .restricted || author == .denied) {
//        return false
//    } else {
//        return true
//    }
    return true
}

// MARK: - 根据image计算放大之后的frame

func calculateFrameWithImage(image : UIImage) -> CGRect {
    let screenW = UIScreen.main.bounds.width
    let screenH = UIScreen.main.bounds.height

    let w = screenW
    let h = screenW / image.size.width * image.size.height
    let x : CGFloat = 0
    let y : CGFloat = (screenH - h) * 0.5
    
    return CGRect(x: x, y: y, width: w, height: h)
}

extension CALayer {
    var borderColorFromUIColor: UIColor {
        get {
            return UIColor(cgColor: self.borderColor!)
        } set {
            self.borderColor = newValue.cgColor
        }
    }
}

// MARK: -- json

func toJsonString(_ jsonObject: Any) -> String {
    if JSONSerialization.isValidJSONObject(jsonObject) {
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: []) {
            if let rString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return rString
            }
        }
    }
    return ""
}
