//
//  SSTMyAccountVC.swift
//  sst-ios
//
//  Created by Amy on 16/6/15.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTMyProfileVC: SSTBaseTVC{

    @IBOutlet weak var genderBtn: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var avatarBtn: UIButton!
    
    fileprivate lazy var pickVC: UIImagePickerController = {
        let pickVC = UIImagePickerController()
        pickVC.delegate = self
        pickVC.allowsEditing = true
        return pickVC
    }()
    fileprivate var avatarData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        nameField.resignFirstResponder()

    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section > 0 else {
            return 0
        }
        return 10
    }
       
    @IBAction func clickAvatarEvent(_ sender: AnyObject) {
        nameField.resignFirstResponder()
        let iconActionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        iconActionSheet.addAction(UIAlertAction(title:"Camera", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.openCamera()
            
        }))
        iconActionSheet.addAction(UIAlertAction(title:"Photo", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.openPhotoLibrary()
            
        }))
        iconActionSheet.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler:nil))
        self.present(iconActionSheet, animated: true, completion: nil)

    }
    
    
    @IBAction func chooseGenderEvent(_ sender: AnyObject) {
        nameField.resignFirstResponder()

        let iconActionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        iconActionSheet.addAction(UIAlertAction(title:"Male", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.genderBtn.setTitle("Male", for: UIControlState())
        }))
        iconActionSheet.addAction(UIAlertAction(title:"Female", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.genderBtn.setTitle("Female", for: UIControlState())
            
        }))
        iconActionSheet.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler:nil))
        self.present(iconActionSheet, animated: true, completion: nil)
    }
    
}

//MARK:-- textField delegate
extension SSTMyProfileVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignFirstResponder()
        guard textField.text?.isNotEmpty != nil else {
            return
        }
        nameField.text = textField.text
    }
}

//MARK:-- imagePicker delegate
extension SSTMyProfileVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    //打开相机
    fileprivate func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickVC.sourceType = .camera
            self.present(pickVC, animated: true, completion: nil)
        } else {
            SSTToastView.showError("This camera is invalid!")
        }
    }
    
    //打开相册
    fileprivate func openPhotoLibrary() {
        pickVC.sourceType = .photoLibrary
        pickVC.allowsEditing = true
        present(pickVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let typeStr = info[UIImagePickerControllerMediaType] as? String {
            if typeStr == "public.image" {
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    let smallImage = UIImage.imageClipToNewImage(image, newSize:CGSize(width: 90, height: 90 ))
                    if UIImagePNGRepresentation(smallImage) == nil {
                        avatarData = UIImageJPEGRepresentation(smallImage, 0.8)
                    } else {
                        avatarData = UIImagePNGRepresentation(smallImage)
                    }
                    if avatarData != nil {
                        //save to local
                        FileOP.archive(kAvatarFileName, object: avatarData!)
                        //设置avatar圆角边缘颜色及宽度
                        let image = UIImage.imageWithClipImage(UIImage(data: avatarData!)!, borderWidth: 2, borderColor: UIColor.white)
                        avatarBtn.setImage(image, for: UIControlState())
                    } else {
                        SSTToastView.showError("save photo failure")
                    }
                }
            }
        } else {
            SSTToastView.showError("get photo failure")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
