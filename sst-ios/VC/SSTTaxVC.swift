//
//  SSTTAXVC.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/12/28.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import PhotosUI

class SSTTaxVC: SSTBaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!

    fileprivate lazy var animator : XTPhotoBrowserAnimator = XTPhotoBrowserAnimator()
    fileprivate lazy var pickVC: UIImagePickerController = {
        let pickVC = UIImagePickerController()
        pickVC.delegate = self
        pickVC.allowsEditing = false
        
        return pickVC
    }()
    
    
    var editButton: UIBarButtonItem!
    var imageViewArray = [UIImageView]()
    var imageArray = [UIImage]()
    var imageUrlArray = [String]()
    var titleArray = [String]()
    var dataArray = [AnyObject]()
    var imageWillDeleteArray = [UIImage]()
    var imageLoading = UIImage() //这个图片是上传过程中的临时占位图
    var addImage : UIImage!
    var businessLicenseImage : UIImage!
    var idImage : UIImage!
    
    var addCodFile = SSTApplyCodFile()
    var applyCodFileList = [SSTApplyCodFile]() //两个模拟数据
    var applyCOD = SSTApplyCod() // 数据
    var appForCOD : SSTToAppForCOD!
    var auditView : SSTAuditView!
    var appForCODFail : SSTAppForCODFail!
    var taxTime: SSTTAXTime!
    var CODCellNow : SSTCODCell!
    var recordsView : SSTRecordsView!
    
    var appForCODHeight:CGFloat = 0
    var auditViewHeight:CGFloat = 0
    var failHeight:CGFloat = 0
    var tagLoading:Int = -1
    
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        let appForCODtitleHegiht = kSSTTAXInvalidTitle.sizeByWidth(font: 15, width: kScreenWidth - 106).height
        let appForCODcontentHegiht = kSSTTAXInvalidContent.sizeByWidth(font: 12, width: kScreenWidth - 106).height
        appForCODHeight = appForCODtitleHegiht + appForCODcontentHegiht + 70
        
        let auditViewtitleHegiht = kSSTTAXDeniedTitle.sizeByWidth(font: 15, width: kScreenWidth - 106).height
        let auditViewcontentHegiht = kSSTTAXDeniedContent.sizeByWidth(font: 13, width: kScreenWidth - 106).height
        
        auditViewHeight = auditViewtitleHegiht + auditViewcontentHegiht + 70

        if let tmpImg = UIImage(named: "icon_addfile") {
            addImage = tmpImg
        }
        
        addCodFile.imageType = .addImage
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.done, target: self, action: #selector(SSTTaxVC.editEvent))
        
        self.navigationItem.rightBarButtonItem = nil;
        
        collectionView.register(UINib(nibName: "\(SSTCODCell.classForCoder())", bundle: nil), forCellWithReuseIdentifier: kCodImageCell)
        collectionView.register(initNib("\(kBlankHeaderView)"), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBlankHeaderView)

        imageViewArray.removeAll()
        self.collectionView.reloadData()
        
        appForCOD =  loadNib("SSTToAppForCOD") as! SSTToAppForCOD  //未提交
        appForCOD.frame = CGRect(x: 0, y: 30, width: kScreenWidth, height: appForCODHeight)
        appForCOD.isHidden = true
        appForCOD.viewRecorsEvent = {
            self.showRecorsView()
        }
        
        auditView =  loadNib("SSTAuditView") as! SSTAuditView // 审核中
        auditView.frame = CGRect(x: 0, y: 30, width: kScreenWidth, height: auditViewHeight)
        auditView.isHidden = true
        auditView.viewRecorsEvent = {
            self.showRecorsView()
        }
        
        appForCODFail =  loadNib("SSTAppForCODFail") as! SSTAppForCODFail //失败
        appForCODFail.frame = CGRect(x: 0, y: 30, width: kScreenWidth, height: 94)
        appForCODFail.isHidden = true
        appForCODFail.viewRecorsEvent = {
            self.showRecorsView()
        }

        taxTime = loadNib("SSTTAXTime") as! SSTTAXTime
        taxTime.frame = CGRect(x: 0, y: 6, width: kScreenWidth, height: 30)
        taxTime.isHidden = true
        
        recordsView = loadNib("\(SSTRecordsView.classForCoder())") as! SSTRecordsView
        recordsView.frame = CGRect(x: 0, y: kScreenNavigationHeight, width: kScreenWidth, height: kScreenViewHeight )
        recordsView.isHidden = true
        recordsView.recordViewHiddlenEvent = {
            self.recordsView.isHidden = true
        }
        self.view.addSubview(recordsView)
        
        applyCOD.delegate = self
        self.upPullLoadData()
    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.upPullLoadData()
    }
    
    func upPullLoadData() {
        SSTProgressHUD.show(view: self.view)
        applyCOD.getApplyTaxFree()
    }
    
    func showRecorsView(){
        recordsView.isHidden = false
        recordsView.fetchData(.tax)
    }
    
    
    @objc func editEvent() {
        if editButton.title == "Done" { // 删除
            editButton.title = "Edit"
        }else { // 编辑
            editButton.title = "Done"
        }
        self.collectionView.reloadData()
    }
    
}
// MARK: -- collectionView delegate
extension SSTTaxVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return applyCOD.applyCodFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCodImageCell, for: indexPath) as! SSTCODCell
        
        let conFile = self.applyCOD.applyCodFiles[indexPath.row]
        
        cell.codFile = conFile
        cell.nameTextField.textColor = UIColor.black
        cell.businessOrIdView.isHidden = true
        cell.editImage.isHidden = false
        cell.nameTextField.isHidden = false

        if conFile.imageType == CODImageType.addImage {
            cell.businessOrIdView.isHidden = false
            cell.businessOrIdLabel.text = "Add file"
            cell.businessOrIdImageView.image = UIImage(named: "icon_addfile")
            cell.editImage.isHidden = true
            cell.nameTextField.isHidden = true
        } else if conFile.imageType == CODImageType.businessImage {
            if conFile.image != nil {
                cell.imageView.image = conFile.image
            } else {
                if self.applyCOD.applyCodFiles[indexPath.item].filepath == "" {
                    cell.businessOrIdView.isHidden = false
                    cell.businessOrIdLabel.text = "Add Business License"
                    cell.businessOrIdImageView.image = UIImage(named: "icon_addBusinesslicense")
                } else {
                    cell.businessOrIdView.isHidden = true
                    setImage(cell: cell, indexPath: indexPath)
                }
            }
            cell.nameTextField.text = kBusinessLicense
            cell.nameTextField.isUserInteractionEnabled = false
            cell.editImage.isHidden = true
        } else if conFile.imageType == CODImageType.idImage {
            if conFile.image != nil {
                cell.imageView.image = conFile.image
            } else {
                if self.applyCOD.applyCodFiles[indexPath.item].filepath == "" {
                    cell.businessOrIdView.isHidden = false
                    cell.businessOrIdLabel.text = "Add ID"
                    cell.businessOrIdImageView.image = UIImage(named: "icon_addID")
                } else {
                    cell.businessOrIdView.isHidden = true
                    setImage(cell: cell, indexPath: indexPath)
                }
            }
            cell.nameTextField.text = "ID"
            cell.nameTextField.isUserInteractionEnabled = false
            cell.editImage.isHidden = true
        } else {
            if conFile.image != nil {
                cell.imageView.image = conFile.image
            } else {
                setImage(cell: cell, indexPath: indexPath)
            }
            cell.editImage.isHidden = true
            cell.nameTextField.text = self.applyCOD.applyCodFiles[indexPath.item].filetitle
            cell.nameTextField.isUserInteractionEnabled = true
            cell.editImage.isHidden = false
        }
        
        cell.editTitle = { title in
            let codFile = cell.codFile
            self.applyCOD.updateTAXNameById(validInt(codFile?.fileid), title: validString(title), callback: { (data, error) in
                self.applyCOD.getApplyTaxFree()
            })
        }
        
        cell.deleteButton.setBackgroundImage(UIImage(named: "icon_cod_delete"), for: UIControlState())
        
        if applyCOD.status != 1 {
            if conFile.imageType == CODImageType.addImage {
                cell.deleteButton.isHidden = true
            } else {
                if editButton.title == "Done" {
                    if conFile.filepath != "" {
                        cell.deleteButton.isHidden = false
                    }else {
                        cell.deleteButton.isHidden = true
                    }
                } else {
                    cell.deleteButton.isHidden = true
                }
            }
        } else {
            cell.deleteButton.isHidden = true
        }
        
        cell.item = indexPath.row
        cell.selectImage = { image in
            let codFile = cell.codFile
            self.applyCOD.deleteTAXImageById(validInt(codFile?.fileid), callback: { (data, error) in
                self.applyCOD.getApplyTaxFree()
            })
        }

        if self.applyCOD.status == 1 {
            cell.nameTextField.isUserInteractionEnabled = false
        }

        return cell
    }
    
    func setImage(cell:SSTCODCell, indexPath:IndexPath) {
        if indexPath.row == tagLoading {
            cell.imageView.setImageWithImage(fileUrl: self.applyCOD.applyCodFiles[indexPath.item].filepath, placeImage: imageLoading)
        } else {
            cell.imageView.setImage(fileUrl: self.applyCOD.applyCodFiles[indexPath.item].filepath, placeholder: kIcon_loading)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
       
        if self.applyCOD.status != nil {
            if self.applyCOD.status == -1 {
                if self.applyCOD.dueTime != nil {
                   return CGSize(width: kScreenWidth, height: appForCODHeight )
                } else {
                   return CGSize(width: kScreenWidth, height: appForCODHeight - 30 )
                }
            }else{
                if self.applyCOD.status == 0 { //审核中
                    return CGSize(width: kScreenWidth, height: auditViewHeight )
                }else if self.applyCOD.status == 1 {  // 审核通过
                    return CGSize(width: kScreenWidth, height: 94)
                }else if self.applyCOD.status == 2{  // 审核失败
                    return CGSize(width: kScreenWidth, height: failHeight)
                }else {
                    return CGSize.zero
                }
            }
        } else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var headView = UICollectionReusableView()
        headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBlankHeaderView, for: indexPath) as! SSTBlankHeaderView
        headView.backgroundColor = UIColor.white
       
        if self.applyCOD.status != nil {
            if kind == UICollectionElementKindSectionHeader {
                if self.applyCOD.status == -1 {
                    headView.addSubview(appForCOD)
                    headView.addSubview(taxTime)
                } else {
                    if self.applyCOD.status == 0 { //审核中
                        headView.addSubview(auditView)
                        headView.addSubview(taxTime)
                    } else if self.applyCOD.status == 1 {  // 审核通过
                        headView.addSubview(appForCODFail)
                        headView.addSubview(taxTime)
                    } else if self.applyCOD.status == 2 {  // 审核失败
                        headView.addSubview(appForCODFail)
                        headView.addSubview(taxTime)
                    }
                }
            }
        }
        return headView
    }
    
    func getCodFiles() -> [SSTApplyCodFile] {
        var showViewCodFiles = [SSTApplyCodFile]()
        for showViewCodFile in self.applyCOD.applyCodFiles {
            for cell in collectionView.visibleCells {
                if let tCell = cell as? SSTCODCell {
                    if showViewCodFile.filepath == tCell.codFile.filepath {
                        if tCell.codFile.filepath == "" {
                            showViewCodFile.image = nil
                        }else {
                            showViewCodFile.image = tCell.imageView.image
                        }
                    }
                }
            }
            if showViewCodFile.filepath != "" {
                showViewCodFiles.append(showViewCodFile)
            }
        }
        return showViewCodFiles
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        CODCellNow = collectionView.cellForItem(at: indexPath) as! SSTCODCell
        let conFile = self.applyCOD.applyCodFiles[indexPath.item]
        let oldIndexParth = IndexPath(row: indexPath.row, section: indexPath.section)
        
        //判断是否审核通过状态
        
        if (conFile.imageType ==  CODImageType.addImage) {
            if applyCOD.status != 1 { // 非审核通过状态都可以添加图片
                tagLoading = indexPath.row
                self.choseCamera(1)
            }
        } else if (conFile.imageType ==  CODImageType.businessImage || conFile.imageType ==  CODImageType.idImage) {
            if conFile.filepath != "" {
                var codCells = collectionView.visibleCells as! [SSTCODCell]
                var indexp = IndexPath(row: 0, section: 0)
                if self.applyCOD.applyCodFiles[0].filepath == "" && self.applyCOD.applyCodFiles[1].filepath == "" {
                    indexp = IndexPath(row: indexPath.row - 2, section: 0)
                    codCells.remove(at: 0)
                    codCells.remove(at: 0)
                }
                if self.applyCOD.applyCodFiles[0].filepath == "" && self.applyCOD.applyCodFiles[1].filepath != "" {
                    indexp = IndexPath(row: indexPath.row - 1, section: 0)
                    codCells.remove(at: 0)
                }
                if self.applyCOD.applyCodFiles[0].filepath != "" && self.applyCOD.applyCodFiles[1].filepath == "" {
                    //                    indexp = NSIndexPath(forRow: indexPath.row - 1, inSection: 0)
                    codCells.remove(at: 1)
                    
                }
                if self.applyCOD.applyCodFiles[0].filepath != "" && self.applyCOD.applyCodFiles[1].filepath != "" {
                    indexp = indexPath
                }
                
                let vc = XTPhotoBrowserViewController()
                vc.codCells = codCells
                vc.shopsArray = getCodFiles()
                vc.transitioningDelegate = animator
                vc.modalPresentationStyle = .custom
                vc.indexPath = indexp
                
                animator.indexPath =  oldIndexParth
                animator.applyCodFiles = self.applyCOD.applyCodFiles
                animator.presentedDelegate = self
                animator.dismissedDelegate = vc
                
                present(vc, animated: true, completion: nil)
            } else {
                if applyCOD.status != 1 {
                    tagLoading = indexPath.row
                    self.choseCamera(1)
                }
            }
        } else {
            var codCells = collectionView.visibleCells as! [SSTCODCell]
            
            var indexp = IndexPath(row: 0, section: 0)
            if self.applyCOD.applyCodFiles[0].filepath == "" && self.applyCOD.applyCodFiles[1].filepath == ""{
                indexp = IndexPath(row: indexPath.row - 2, section: 0)
                
                codCells.remove(at: 0)
                codCells.remove(at: 0)
            }
            if self.applyCOD.applyCodFiles[0].filepath == "" && self.applyCOD.applyCodFiles[1].filepath != ""{
                indexp = IndexPath(row: indexPath.row - 1, section: 0)
                codCells.remove(at: 0)
            }
            if self.applyCOD.applyCodFiles[0].filepath != "" && self.applyCOD.applyCodFiles[1].filepath == ""{
                indexp = IndexPath(row: indexPath.row - 1, section: 0)
                codCells.remove(at: 0)
            }
            if self.applyCOD.applyCodFiles[0].filepath != "" && self.applyCOD.applyCodFiles[1].filepath != ""{
                indexp = indexPath
            }
            
            let vc = XTPhotoBrowserViewController()
            vc.transitioningDelegate = animator
            vc.modalPresentationStyle = .custom
            
            vc.shopsArray = getCodFiles()
            vc.indexPath = indexp
            animator.indexPath =  oldIndexParth
            animator.applyCodFiles = self.applyCOD.applyCodFiles
            animator.presentedDelegate = self
            animator.dismissedDelegate = vc
            
            present(vc, animated: true, completion: nil)
        }
    }
    
    func choseCamera(_ maxSelectedCount:Int){
        let iconActionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        iconActionSheet.addAction(UIAlertAction(title:"Open Camera", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.openCamera()
            
        }))
        iconActionSheet.addAction(UIAlertAction(title:"View Photo Album", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.openPhotoLibrary(maxSelectedCount)
            
        }))
        iconActionSheet.addAction(UIAlertAction(title:"Cancel", style: UIAlertActionStyle.cancel, handler:nil))
        self.present(iconActionSheet, animated: true, completion: nil)
        
    }
    
    //打开相机
    fileprivate func openCamera() {
        
        if  isCanUseCamera() {
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickVC.sourceType = .camera
                
                self.present(pickVC, animated: true, completion: nil)
            } else {
                SSTToastView.showError("Unable to open camera!")
            }
            
        }else{
            let alertView = SSTAlertView(title: "Photo Album", message: kOpenCameraMessage)
            alertView.addButton("NO") {
            }
            
            alertView.addButton("Setting Now") {
                if let tmpUrl = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(tmpUrl)
                }
            }
            alertView.show()
        }
    }
    
    //打开相册
    fileprivate func openPhotoLibrary(_ maxSelectedCount:Int) {
        
        if  isCanUseCamera() {
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickVC.sourceType = .photoLibrary
                
                self.present(pickVC, animated: true, completion: nil)
            } else {
                SSTToastView.showError("This camera is invalid!")
            }
            
        }else{
            let alertView = SSTAlertView(title: "Photo Album", message: kOpenCameraMessage)
            alertView.addButton("NO") {
            }
            
            alertView.addButton("Setting Now") {
                if let tmpUrl = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(tmpUrl)
                }
            }
            alertView.show()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemSize = CGSize(width: kScreenWidth/2, height: 160*kProkScreenWidth)
        return itemSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0*kProkScreenWidth, bottom: 0, right: 0*kProkScreenWidth)
    }
    //动态设置每行的间距大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10*kProkScreenWidth;
    }
    //动态设置每列的间距大小
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0*kProkScreenWidth;
    }
    
    func insertAddImage(){
        if self.applyCOD.applyCodFiles.count < 6 {
            
            let includeAddImage = self.applyCOD.applyCodFiles.contains { (codFile) -> Bool in
                if codFile.imageType == self.addCodFile.imageType {
                    return true
                }else {
                    return false
                }
            }
            
            if includeAddImage == false {
                self.applyCOD.applyCodFiles.append(addCodFile)
            }
        }
        
    }
    
    func removeAddImage() {
        
        let includeAddImage = self.applyCOD.applyCodFiles.contains { (codFile) -> Bool in
            if codFile.imageType == self.addCodFile.imageType {
                return true
            } else {
                return false
            }
        }
        
        if includeAddImage == true {
            self.applyCOD.applyCodFiles.removeLast()
        }
    }
}

//MARK:-- imagePicker delegate
extension SSTTaxVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let typeStr = info[UIImagePickerControllerMediaType] as? String {
            if typeStr == "public.image" {
                
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                imageLoading = image
                //弹窗，填写title
                let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
                bgView.backgroundColor = RGBA(211, g: 211, b: 211, a: 1)
                bgView.alpha = 0.5
                
                let imageTitleView = loadNib("SSTImageTitle") as! SSTImageTitle  //未提交
                imageTitleView.frame = CGRect(x: 80*kProkScreenWidth, y: (kScreenHeight - 246)/2-80, width: kScreenWidth - 160*kProkScreenWidth, height: 226)
                imageTitleView.imageView.image = image
                imageTitleView.imageType = self.CODCellNow.codFile.imageType
                if self.CODCellNow.codFile.imageType == .businessImage {
                    imageTitleView.textField.text = kBusinessLicenseTitle
                    imageTitleView.textField.isUserInteractionEnabled = false
                }
                if self.CODCellNow.codFile.imageType == .idImage {
                    imageTitleView.textField.text = kID
                    imageTitleView.textField.isUserInteractionEnabled = false
                } else {
                    imageTitleView.textField.resignFirstResponder()
                }
                
                imageTitleView.imageTitleClick = { title, willUpload in
                    self.dismiss(animated: true, completion: nil)
                    
                    bgView.removeFromSuperview()
                    imageTitleView.removeFromSuperview()
                    if willUpload {
                        self.uploadImage(title, image: image)
                    }
                    picker.dismiss(animated: true, completion: nil)
                }
                
                picker.view.addSubview(bgView)
                picker.view.addSubview(imageTitleView)
            }
        } else {
            SSTToastView.showError(kCODOpenPhotoFailedText)
        }
    }
    
    func uploadImage(_ title :String, image : UIImage){
        SSTProgressHUD.showWithMaskOverFullScreen()
        if self.CODCellNow.codFile.imageType != .addImage {
            let conFile = self.CODCellNow.codFile
            conFile?.filetitle = title
            conFile?.image = image
            
            if conFile?.fileid != nil {  // 删除 图片
                self.applyCOD.deleteTAXImageById(validInt(conFile?.fileid), callback: { (data, error) in    // 上传图片
                    self.applyCOD.uploadTAXImage(image, title:title, callback: { (data, error) in
                        SSTProgressHUD.dismiss(view: self.view)
                        if error == nil {
                            SSTToastView.showSucceed(kCODUploadImageSuccessText)
                            self.applyCOD.getApplyTaxFree()
                        } else {
                            SSTToastView.showError(kCODUploadImageFailedText)
                        }
                    })
                })
            } else { // 上传图片
                self.applyCOD.uploadTAXImage(image, title:title, callback: { (data, error) in
                    SSTProgressHUD.dismiss(view: self.view)
                    if error == nil {
                        SSTToastView.showSucceed(kCODUploadImageSuccessText)
                        self.applyCOD.getApplyTaxFree()
                    } else {
                        SSTToastView.showError(kCODUploadImageFailedText)
                    }
                })
            }
        } else {
            
            //创建一个新的对象
            let codFile = SSTApplyCodFile()
            codFile.filetitle = title
            codFile.image = image
            
            self.applyCOD.applyCodFiles.insert(codFile, at: self.applyCOD.applyCodFiles.count - 1)
            
            if self.applyCOD.applyCodFiles.count > 6 {
                self.removeAddImage()
            }
            
            // 上传图片
            self.applyCOD.uploadTAXImage(image, title:title, callback: { (data, error) in
                SSTProgressHUD.dismiss(view: self.view)
                if error == nil {
                    SSTToastView.showSucceed(kCODUploadImageSuccessText)
                    self.applyCOD.getApplyTaxFree()
                } else {
                    self.applyCOD.applyCodFiles.last?.imageType = CODImageType.addImage
                    self.collectionView.reloadData()
                    SSTToastView.showError(kCODUploadImageFailedText)
                }
            })
        }
        
        self.collectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SSTTaxVC: SSTUIRefreshDelegate {
    
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
//        collectionView.headerView?.endRefreshing()
        imageViewArray.removeAll()
        
        auditView.removeFromSuperview()
        appForCODFail.removeFromSuperview()
        appForCOD.removeFromSuperview()
        taxTime.removeFromSuperview()
        
        // 未提交
        if self.applyCOD.status == -1 {
            appForCOD.isHidden = false
            appForCOD.titleLabel.text = kSSTTAXInvalidTitle
            appForCOD.contentLabel.text = kSSTTAXInvalidContent
           
            auditView.isHidden = true
            appForCODFail.isHidden = true
            
            if self.applyCOD.dueTime != nil {
                if self.applyCOD.dueTime! < Date() {
                    taxTime.timeLabel.text = "Tax Exemption allowance period expired"
                }else {
                    taxTime.timeLabel.text = "Expiration Date: \(validString(self.applyCOD.dueTime?.formatMMddyy()))"
                }
                taxTime.frame = CGRect(x: 0, y: 6, width: kScreenWidth, height: 30)
                taxTime.isHidden = false
                appForCOD.frame = CGRect(x: 0, y: 30, width: kScreenWidth, height: appForCODHeight)
            } else {
                appForCOD.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: appForCODHeight)
                taxTime.isHidden = true
            }
            self.navigationItem.rightBarButtonItem = editButton
            self.insertAddImage()
            
        }else{
            if self.applyCOD.status == 0 { //审核中
                self.navigationItem.rightBarButtonItem = editButton
                auditView.isHidden = false
                appForCOD.isHidden = true
                appForCODFail.isHidden = true
                taxTime.isHidden = false
                auditView.titleLabel.text = kSSTTAXDeniedTitle
                auditView.contentLabel.text = kSSTTAXDeniedContent
                self.insertAddImage()
                if self.applyCOD.dueTime != nil {
                    if self.applyCOD.dueTime! < Date() {
                        taxTime.timeLabel.text = "Tax Exemption allowance period expired"
                    }else {
                         taxTime.timeLabel.text = "Expiration Date: \(validString(self.applyCOD.dueTime?.formatMMddyy()))"
                    }
                    taxTime.frame = CGRect(x: 0, y: 6, width: kScreenWidth, height: 30)
                    auditView.frame = CGRect(x: 0, y: 30, width: kScreenWidth, height: auditViewHeight - 30)
                }else {
                    taxTime.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 0)
                    auditView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: auditViewHeight - 30)
                }
            }else if self.applyCOD.status == 1 {  // 审核通过
                self.navigationItem.rightBarButtonItem = UIBarButtonItem()
                auditView.isHidden = true
                appForCOD.isHidden = true
                appForCODFail.isHidden = false
                taxTime.isHidden = true // hidden when aplly successfully
                appForCODFail.iconImge.image = UIImage(named: "icon_select_sel")
                appForCODFail.titleLabel.text = kSSTTAXApprovedTitle
                appForCODFail.contentLabel.text = kSSTTAXApprovedContent
                appForCODFail.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 94)
                taxTime.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 0)
            }else if self.applyCOD.status == 2{  // 审核失败
                self.navigationItem.rightBarButtonItem = editButton
                auditView.isHidden = true
                appForCOD.isHidden = true
                appForCODFail.isHidden = false
                taxTime.isHidden = false
                
                appForCODFail.iconImge.image = UIImage(named: "icon_more_cod_fail")
                appForCODFail.titleLabel.text = kSSTTAXRejectedTitle
                appForCODFail.contentLabel.text = self.applyCOD.denyreason
                
                if self.applyCOD.dueTime != nil {
                    if self.applyCOD.dueTime! < Date() {
                        taxTime.timeLabel.text = "Tax Exemption allowance period expired"
                    }else {
                        taxTime.timeLabel.text = "Expiration Date: \(validString(self.applyCOD.dueTime?.formatMMddyy()))"
                    }
                    taxTime.frame = CGRect(x: 0, y: 6, width: kScreenWidth, height: 30)
                    
                }else {
                    taxTime.frame = CGRect(x: 0, y: 6, width: kScreenWidth, height: 0)
                }
                
                let appForCODFailtitleHegiht = kSSTTAXRejectedTitle.sizeByWidth(font: 15, width: kScreenWidth - 135).height
                let appForCODFailcontentHegiht = self.applyCOD.denyreason.sizeByWidth(font: 13, width: kScreenWidth - 135).height
                failHeight = appForCODFailtitleHegiht + appForCODFailcontentHegiht + 77
                appForCODFail.frame = CGRect(x: 0, y: 30, width: kScreenWidth, height: failHeight - 30)
                self.insertAddImage()
            }
        }
        collectionView.reloadData()
    }
    
}

extension SSTTaxVC : AnimatorPresentedDelegate {
    
    func startRect(_ indexPath: IndexPath) -> CGRect {
        guard let cell = collectionView?.cellForItem(at: indexPath) else {
            return CGRect.zero
        }
        let cellFrame  = cell.frame
        
        if let startRect = collectionView?.convert(cellFrame, to: UIApplication.shared.keyWindow) {
            return startRect
        }
        return CGRect()
    }
    
    func endRect(_ indexPath: IndexPath) -> CGRect {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? SSTCODCell else {
            return CGRect.zero
        }
        guard let image = cell.imageView.image else {
            return CGRect.zero
        }
        return calculateFrameWithImage(image: image)
    }
    
    
    func imageView(_ indexPath: IndexPath) -> UIImageView {
        let imageView = UIImageView()
        guard let cell = collectionView?.cellForItem(at: indexPath) as? SSTCODCell else {
            return imageView
        }
        guard let image = cell.imageView.image else {
            return imageView
        }
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }
}
