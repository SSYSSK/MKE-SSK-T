//
//  SSTPaypalWebVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 12/13/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit

let kPaypalCreatePaymentUrl = kPayURLString + "web/paymentwithpaypal/pay.d"
let kPaypalCancelPaymentUrl = kPayURLString + "web/paymentwithpaypal/cancel.d"

class SSTPaypalWebVC: SSTWebVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    @IBAction func clickedBackButton(_ sender: Any) {
        let alertController = UIAlertController(title: "", message: kPaypalCancelTip, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            self.cancelPay()
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func cancelPay() {
        self.dismiss(animated: true, completion: {
            if let basePayVC = (gMainTC?.selectedViewController as? UINavigationController)?.childViewControllers.last as? SSTBasePayVC {
                basePayVC.doPayWithPaypalDidCancel()
            }
        })
    }
    
    // MARK: -- UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        self.webView.endEditing(true)
        return true
    }
    
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        if validString(webView.request?.url?.host).contains("paypal.com") {
            SSTProgressHUD.dismiss(view: self.view)
        } else if validString(webView.request?.url?.absoluteString).contains("cancel=1") {
            self.cancelPay()
        } else if validString(webView.request?.url?.absoluteString).contains("billingId") {
            let rDict = validString(webView.stringByEvaluatingJavaScript(from: "document.getElementById('result').innerHTML")).toDictionary()
            if let basePayVC = (gMainTC?.selectedViewController as? UINavigationController)?.childViewControllers.last as? SSTBasePayVC {
                if validInt(rDict?["code"]) == 200 {
                    basePayVC.doPayWithPaypalDidComplete(error: nil, msg: SSTBasePayVC.getPaymentMsg(dict: rDict))
                } else {
                    basePayVC.doPayWithPaypalDidComplete(error: rDict, msg: validString(rDict?["msg"]))
                }
            } else {
                SSTToastView.showError("Error: Cannot back to pay vc!")
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
