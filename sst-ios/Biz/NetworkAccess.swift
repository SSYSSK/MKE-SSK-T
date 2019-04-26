//
//  NetworkAccess.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/27/16.
//  Copyright © 2016 po. All rights reserved.
//

import UIKit
import Gzip
import Alamofire

let kNetworkStatusNofication         = "network_changed"
let kNetworkTimeoutInterval: Double  = 30

public typealias RequestCallBack = (_ data: Any?, _ error:Any?) -> Void
public typealias ErrorCallBack   = (_ errorCode: Any?) -> Bool

class GZipEncoding : ParameterEncoding {
    func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var mRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: parameters)
        
        if mRequest.httpBody != nil {
            if let httpBody = try? mRequest.httpBody?.gzipped() {
                mRequest.httpBody = httpBody
                mRequest.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
            }
        }
        
        return mRequest
    }
}

let gzipEncoding = GZipEncoding()

class NetworkAccess {
    
    let networkReachabilityManager = NetworkReachabilityManager(host: "www.apple.com")
    let mAlamofire:SessionManager!
    var mHeader:[String: String]
    
    var networkIsAvailable = false
    
    weak var signInAC: UIAlertController?
    
    init() {
        
        let serverTrustPolicy = ServerTrustPolicy.performDefaultEvaluation(
            validateHost: true
        )
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "127.0.0.1": .disableEvaluation,
            "*.sstparts.com" : serverTrustPolicy
        ]
        
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        defaultHeaders["Accept"] = "application/json"
        defaultHeaders["Content-Type"] = "application/json"
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        configuration.timeoutIntervalForRequest = kNetworkTimeoutInterval
        
        mAlamofire = Alamofire.SessionManager(configuration: configuration, serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies))
        
        mHeader = [
            "version": kAppBuild
        ]
    }
    
    func listen() {
        networkReachabilityManager?.listener = { status in
            printDebug("Network Status Changed: \(status)")
            var dict = ["status":"Reachable"]
            if status == .notReachable {
                dict = ["status":"NotReachable"]
                self.networkIsAvailable = false
            } else {
                dict = ["status":"Reachable"]
                self.networkIsAvailable = true
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNetworkStatusNofication), object: dict)
        }
        networkReachabilityManager?.startListening()
    }
    
    func resetViewAfterCancelWhenLoginByAntherAccount() {
        biz.cart.fetchData()
        if let childControllers = gMainTC?.childViewControllers {
            for nc in childControllers {
                if let vc = (nc as? UINavigationController)?.childViewControllers.last {
                    if vc.responds(to: #selector(SSTHomeVC.resetViewAfterCancelWhenLoginByAntherAccount)) {
                        vc.perform(#selector(SSTHomeVC.resetViewAfterCancelWhenLoginByAntherAccount))
                    }
                }
            }
        }
    }
    
    func request(_ method: HTTPMethod, url: String, parameters: [String: Any]? = nil, user: SSTUser? = biz.user, callback: RequestCallBack? = nil) {
        
        let tmpUrl = url.toUrl()
        
        if parameters != nil {
            if !JSONSerialization.isValidJSONObject(parameters!) {
                printDebug("Error: The parameters of url '" + tmpUrl + "' is not a valid json")
                return
            }
        }
        
        printDebug("url: \(tmpUrl), parameters: \(toJsonString(validDictionary(parameters)))")
        
        mHeader["app_token"] = validString(user?.token)
        mHeader["dev_os_type"] = "1"
        
        printDebug(NSTimeZone.system.identifier)
        mHeader["client_timezone"] = NSTimeZone.system.identifier
        let request = mAlamofire.request(tmpUrl, method: method, parameters: parameters, encoding: gzipEncoding, headers: mHeader)
            .validate()
            .responseJSON { response in
                self.handleResponse(method: method, url: tmpUrl, parameters: parameters, user: user, response: response) { data, error in
                    callback?(data, error)
                }
        }
        
        printDebug(request)
    }
    
    func uploadFile(url: String, files: [UIImage]? = nil, fileFieldName: String = "*", fieldNames: [String]? = nil, fieldValues: [String]? = nil, callback: RequestCallBack? = nil) {
        
        mHeader["app_token"] = biz.user.token
        
        mAlamofire.upload(multipartFormData: { (multipartFormData) in
            for ind in 0 ..< validInt(files?.count) {
                if let file = files?.validObjectAtIndex(ind) as? UIImage {
                    let indString = ind > 0 ? validString(ind) : ""
                    if let imageData = UIImageJPEGRepresentation(file, 0.2) {
                        multipartFormData.append(imageData, withName: fileFieldName + indString, fileName: "image\(validString(ind)).jpg", mimeType: "image/jpg")
                    } else if let imageData = UIImagePNGRepresentation(file) {
                        multipartFormData.append(imageData, withName: fileFieldName + indString, fileName: "image\(validString(ind)).png", mimeType: "image/png")
                    }
                }
            }
            for ind in 0 ..< validInt(fieldNames?.count) {
                multipartFormData.append(fieldValues![ind].data(using: String.Encoding.utf8)!, withName: fieldNames![ind])
            }
        }, usingThreshold: 20480, to: url.toUrl(), method: .post, headers: mHeader) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    printDebug(response)
                    self.handleResponse(method: .post, url: url, parameters: nil, user: biz.user, response: response) { data, error in
                        callback?(data, error)
                    }
                }
            case .failure(let encodingError):
                callback?(nil, encodingError)
            }
        }
    }
    
    func handleResponse(method: HTTPMethod, url: String, parameters: [String: Any]? = nil, user: SSTUser? = biz.user, response: DataResponse<Any>, callback: RequestCallBack? = nil) {
        printDebug(response)
        
        switch response.result {
        case .success:
            self.networkIsAvailable = true  // ensure the network status is updated immediately when request is ok
            let jsonObject = validDictionary(try? JSONSerialization.jsonObject(with: response.data!, options:JSONSerialization.ReadingOptions.allowFragments))
            switch validInt(jsonObject["code"]) {
            case APICodeType.Ok.rawValue:
                callback?(jsonObject["data"], nil)
            case APICodeType.InvalidToken.rawValue:
                user?.updateGuestToken({ (data, error) in
                    if error == nil && validString(user?.token) != "" {
                        self.request(method, url: url, parameters: parameters, callback: callback)
                    } else {
                        callback?(nil, error)
                    }
                })
            case APICodeType.NotLogined.rawValue:
                if signInAC != nil {
                    return
                }
                presentLoginVC({ (data, error) in
                    if error == nil {
                        self.request(method, url: url, parameters: parameters, callback: callback)
                    } else {
                        user?.type = false
                        callback?(nil, "")
                    }
                })
            case APICodeType.LoginWithAnotherDevice.rawValue:
                if signInAC != nil {
                    return
                }
                let cancelBlock = {
                    biz.user?.updateGuestToken({ (data, error) in
                        user?.type = false
                        callback?(nil, "")
                        self.resetViewAfterCancelWhenLoginByAntherAccount()
                    })
                }
                let mAC = UIAlertController(title: "", message: kAccountSignOutByAnotherDeviceTip, preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                    cancelBlock()
                })
                let signInAction = UIAlertAction(title: "Sign In", style: .default, handler: { action in
                    presentLoginVC({ (data, error) in
                        if error == nil {
                            self.request(method, url: url, parameters: parameters, callback: callback)
                        } else {
                            cancelBlock()
                        }
                    })
                })
                mAC.addAction(cancelAction)
                mAC.addAction(signInAction)
                getTopVC()?.present(mAC, animated: true, completion: nil)
                signInAC = mAC
            default:
                printDebug("SERVER API ERROR: " + validString(jsonObject["msg"]))
                callback?(validInt(jsonObject["code"]), validString(jsonObject["msg"]))
            }
        case .failure(let error):
            callback?(nil, error.localizedDescription)
        }
    }
    
}
