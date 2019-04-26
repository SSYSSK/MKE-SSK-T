//
//  SSTContactAddVC.swift
//  sst-ios
//
//  Created by Zal Zhang on 9/20/17.
//  Copyright © 2017 ios. All rights reserved.
//

import UIKit
import Photos
import NohanaImagePicker

class SSTContactAddVC: SSTBaseVC, UITextFieldDelegate, UITextViewDelegate, NohanaImagePickerControllerDelegate {

    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var detailTF: UITextView!
    @IBOutlet weak var detailPlaceholderLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    
    let picker = NohanaImagePickerController()
    
    let imgViewWidth: CGFloat = (kScreenWidth - 50) / 4
    var imgViews: [UIImageView] = [UIImageView]()
    var imgViewsIndClicked: Int = 0
    var imgViewsIndSelected: Int?   // ind which is selected with image
    
//    fileprivate lazy var pickVC: UIImagePickerController = {
//        let pickVC = UIImagePickerController()
//        pickVC.delegate = self
//        pickVC.allowsEditing = false
//        return pickVC
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        picker.maximumNumberOfSelection = 3
        
        titleTF.delegate = self
        detailTF.delegate = self
        
        detailTF.cornerRadius = 5
        
        appendImgVToImgViews(ind: 0)
    }
    
    func appendImgVToImgViews(ind: Int) {
        let imgV = UIImageView(frame: CGRect(x: 5 + validCGFloat(ind) * (imgViewWidth + 5), y: validCGFloat(detailTF.superview?.height) - imgViewWidth - 5, width: imgViewWidth, height: imgViewWidth))
        imgV.image = UIImage(named: "contact_add")
        imgV.tag = ind
        imgV.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(SSTContactAddVC.selectImage(_:)))
        imgV.addGestureRecognizer(tap)
        self.detailTF.superview?.addSubview(imgV)
        imgViews.append(imgV)
    }
    
    @objc func selectImage(_ tap: UITapGestureRecognizer) {
//        if imgViewsIndSelected != nil && validInt(tap.view?.tag) <= validInt(imgViewsIndSelected) {
//            let vc = SSTImageViewVC()
//            vc.indexPath = IndexPath(row: validInt(tap.view?.tag), section: 0)
//
//            var imgs = [UIImage]()
//            for ind in 0 ... validInt(imgViewsIndSelected) {
//                if let img = imgViews[ind].image {
//                    imgs.append(img)
//                }
//            }
//
//            vc.imgs = imgs
//            vc.deletable = true
//
//            vc.disappeard = { imgs in
//                if imgs.count - 1 < validInt(self.imgViewsIndSelected) {
//                    for vw in self.imgViews {
//                        vw.removeFromSuperview()
//                    }
//                    self.imgViews.removeAll()
//                    for ind in 0 ..< imgs.count {
//                        self.appendImgVToImgViews(ind: ind)
//                        self.imgViews[ind].image = imgs[ind]
//                    }
//                    self.imgViewsIndSelected = imgs.count - 1
//                    if self.imgViews.count < 3 {
//                        self.appendImgVToImgViews(ind: self.imgViews.count)
//                    }
//                }
//            }
//
//            vc.modalPresentationStyle = .custom
//            self.present(vc, animated: false, completion: nil)
//            return
//        }
        
//        imgViewsIndClicked = validInt(tap.view?.tag)
        
//        let mAC = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
//        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.default) { (UIAlertAction) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                self.pickVC.sourceType = .camera
//                self.present(self.pickVC, animated: true, completion: {
//                    UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
//                })
//            } else {
//                SSTToastView.showError("Unable to open camera!")
//            }
//        }
//        let albumAction = UIAlertAction(title: "Choose from Gallery", style: UIAlertActionStyle.default) { (UIAlertAction) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                self.pickVC.sourceType = .photoLibrary
//                self.present(self.pickVC, animated: true, completion: {
//                    UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
//                })
//            } else {
//                SSTToastView.showError("Unable to open gallery!")
//            }
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
//            //
//        }
//        mAC.addAction(cameraAction)
//        mAC.addAction(albumAction)
//        mAC.addAction(cancelAction)
//
//        self.present(mAC, animated: true, completion: nil)
        
        self.present(picker, animated: true, completion: {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let toBeString = validString((textField.text as NSString?)?.replacingCharacters(in: range, with: string))
        if toBeString.trim().isNotEmpty {
            confirmButton.backgroundColor = RGBA(125, g: 124, b: 254, a: 1)
        } else {
            confirmButton.backgroundColor = UIColor.lightGray
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let toBeString = validString((textView.text as NSString?)?.replacingCharacters(in: range, with: text))
        if toBeString.trim().isNotEmpty {
            detailPlaceholderLabel.isHidden = true
        } else {
            detailPlaceholderLabel.isHidden = false
        }
        return true
    }

    @IBAction func clickedConfirmButton(_ sender: Any) {
        guard validString(titleTF.text).trim().isNotEmpty else {
            SSTToastView.showError("Please enter your title first")
            return
        }
        
        var imgs = [UIImage]()
        if imgViewsIndSelected != nil {
            for ind in 0 ... validInt(imgViewsIndSelected) {
                imgs.append(imgViews[ind].image!)
            }
        }
        SSTProgressHUD.show(view: self.view)
        SSTContactData.addRecord(title: validString(titleTF.text), content: validString(detailTF.text).trim(), files: imgs) { data, error in
            SSTProgressHUD.dismiss(view: self.view)
            if error == nil {
                if let prevVC = self.navigationController?.childViewControllers.validObjectAtLoopIndex(-2) as? SSTContactSSTVC {
                    prevVC.upPullLoadData()
                }
                self.navigationController?.popViewController(animated: true)
            } else {
                SSTToastView.showError(validString(error))
            }
        }
    }
    
    // MARK: -- NohanaImagePickerControllerDelegate
    
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
        picker.dismiss(animated: true, completion: {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        })
    }
    
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts :[PHAsset]) {
        while imgViews.count > 0 {
            imgViews.last?.removeFromSuperview()
            imgViews.removeLast()
        }
        appendImgVToImgViews(ind: 0)
        
        for ind in 0 ..< pickedAssts.count {
            imgViewsIndClicked = ind
            let image = PHAssetToUIImage(asset: pickedAssts[ind])
            addImageToImageViews(image: image)
        }
        
        picker.dismiss(animated: true, completion: {
            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        })
    }
    
    func PHAssetToUIImage(asset: PHAsset) -> UIImage {
        var image = UIImage()
        let imageManager = PHImageManager.default()
        
        let imageRequestOption = PHImageRequestOptions()
        imageRequestOption.isSynchronous = true
        imageRequestOption.resizeMode = .none
        imageRequestOption.deliveryMode = .highQualityFormat
        
        imageManager.requestImage(for: asset, targetSize: kScreenSize, contentMode: .aspectFill, options: imageRequestOption, resultHandler: { (result, _) -> Void in
            image = result!
        })
        
        return image
    }
    
    func addImageToImageViews(image: UIImage) {
        imgViews[imgViewsIndClicked].image = image
        if validInt(imgViewsIndClicked) < 2 {
            appendImgVToImgViews(ind: validInt(imgViewsIndClicked) + 1)
        }
        imgViewsIndSelected = imgViewsIndClicked
    }

}
//
//// MARK: -- imagePicker delegate
//
//extension SSTContactAddVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let typeStr = info[UIImagePickerControllerMediaType] as? String {
//            if typeStr == "public.image" {
//                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//                imgViews[imgViewsIndClicked].image = image
//
//                if imgViewsIndSelected == nil || validInt(imgViewsIndSelected) < imgViewsIndClicked {
//                    imgViewsIndSelected = imgViewsIndClicked
//                }
//
//                if validInt(imgViewsIndSelected) < 2 {
//                    appendImgVToImgViews(ind: validInt(imgViewsIndSelected) + 1)
//                }
//            }
//        } else {
//            SSTToastView.showError(kOpenPhotoFailedText)
//        }
//        picker.dismiss(animated: true, completion: {
//            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
//        })
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        if imgViewsIndClicked >= 1 {
//            imgViewsIndClicked = imgViewsIndClicked - 1
//        }
//        picker.dismiss(animated: true, completion: {
//            UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
//        })
//    }
//}

