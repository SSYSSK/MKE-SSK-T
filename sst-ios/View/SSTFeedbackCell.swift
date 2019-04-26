//
//  SSTFeedbackCell.swift
//  sst-ios
//
//  Created by Amy on 2016/11/2.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTFeedbackCell: SSTBaseCell,UITextViewDelegate {

    @IBOutlet weak var textView: SSTPlaceHolderTextView!
    @IBOutlet weak var confirmBtn: UIButton!
    
    @IBAction func clickedConfirmBtnEvetn(_ sender: AnyObject) {
        self.textView.resignFirstResponder()
        let str = textView.text
        guard str != ""  else {
            SSTToastView.showError("Please enter your feedback first!")
            return
        }
        SSTFeedbackData.uploadFeedback(validString(textView.text)) { (data, error) in
            if error == nil {
                self.textView.text = nil
                SSTToastView.showSucceed(kFeedbacUploadFeedbackSuccessText)
                self.confirmBtn.isEnabled = false
                self.confirmBtn.backgroundColor = RGBA(188, g: 188, b: 188, a: 1)
            } else {
                SSTToastView.showError(kFeedbacUploadFeedbackFailedText)
            }
        }
    }
}

extension SSTFeedbackCell {
    
    @objc(textView:shouldChangeTextInRange:replacementText:) func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n"){
            textView.endEditing(true)
            return false
        } else {
            return true
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.lengthOfBytes(using: .utf8) > 0 {
            confirmBtn.isEnabled = true
            confirmBtn.backgroundColor = kPurpleColor
        } else {
            confirmBtn.isEnabled = false
            confirmBtn.backgroundColor = RGBA(188, g: 188, b: 188, a: 1)
        }
    }
}
