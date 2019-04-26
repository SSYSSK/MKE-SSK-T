//
//  SSTCODVC.swift
//  sst-ios
//
//  Created by Amy on 2016/11/18.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit
import PhotosUI

let kBusinessLicenseTitle = "Business License"
let kBusinessLicense      = "Business License"
let kID                   = "ID"
let kIconBusinessLicense  = "icon_addBusinesslicense"
let kIconAddID            = "icon_addID"
let kCodImageCell         = "SSTCODCell"
let kBlankHeaderView      = "SSTBlankHeaderView"

let appForCODViewHeight:CGFloat = 125.0
let auditViewHeight:CGFloat = 105.0
let appForCODFailViewHeight:CGFloat = 100.0

class SSTCODVC: SSTBaseVC {

    fileprivate lazy var pickVC: UIImagePickerController = {
        let pickVC = UIImagePickerController()
        pickVC.delegate = self
        pickVC.allowsEditing = false
        return pickVC
    }()
    
    fileprivate lazy var animator : XTPhotoBrowserAnimator = XTPhotoBrowserAnimator()

    @IBOutlet weak var collectionView: UICollectionView!
    
    var editButton: UIBarButtonItem!
    var imageViewArray = [UIImageView]()
    var imageArray = [UIImage]()
    var imageUrlArray = [String]()
    var titleArray = [String]()
    var imageWillDeleteArray = [UIImage]()
    var dataArray = [AnyObject]()
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
    var CODCellNow : SSTCODCell!
    var recordsView : SSTRecordsView!
    
    var firstLoad = true
    var failHeight:CGFloat = 0
    var tagLoading:Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addImage = UIImage(named: "icon_addfile")
        addCodFile.imageType = .addImage
        editButton = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.done, target: self, action: #selector(SSTCODVC.editEvent))
        
        self.navigationItem.rightBarButtonItem = nil
        
        collectionView.register(UINib(nibName: "\(SSTCODCell.classForCoder())", bundle: nil), forCellWithReuseIdentifier: kCodImageCell)
        collectionView.register(initNib("\(kBlankHeaderView)"), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBlankHeaderView)
        
        imageViewArray.removeAll()
        self.collectionView.reloadData()
        
        appForCOD =  loadNib("SSTToAppForCOD") as! SSTToAppForCOD  //未提交
        appForCOD.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: appForCODViewHeight)
        appForCOD.isHidden = true
        appForCOD.viewRecorsEvent = {
            self.showRecorsView()
        }
        
        auditView =  loadNib("SSTAuditView") as! SSTAuditView // 审核中
        auditView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: auditViewHeight)
        auditView.isHidden = true
        auditView.viewRecorsEvent = {
            self.showRecorsView()
        }
        
        appForCODFail =  loadNib("SSTAppForCODFail") as! SSTAppForCODFail //失败
        appForCODFail.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: appForCODFailViewHeight)
        appForCODFail.isHidden = true
        appForCODFail.viewRecorsEvent = {
            self.showRecorsView()
        }

        recordsView = loadNib("\(SSTRecordsView.classForCoder())") as! SSTRecordsView
        recordsView.frame = CGRect(x: 0, y: 64, width: kScreenWidth, height: kScreenHeight - 64 )
        recordsView.isHidden = true
        recordsView.recordViewHiddlenEvent = {
            self.recordsView.isHidden = true
        }
        self.view.addSubview(recordsView)

        failHeight = 100
        applyCOD.delegate = self
        self.upPullLoadData()
        //这里发请求是为了知道操作记录是否有数据，如果没有数据，直接隐藏
        recordsView.fetchData(.cod)

    }
    
    @objc func resetViewAfterLoginedByAnotherAccount() {
        self.upPullLoadData()
    }
    
    func upPullLoadData() {
        SSTProgressHUD.show(view: self.view)
        applyCOD.getApplyCod()
    }
    
    func showRecorsView(){
        recordsView.isHidden = false
        recordsView.fetchData(.cod)
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
extension SSTCODVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return applyCOD.applyCodFiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kCodImageCell, for: indexPath) as! SSTCODCell
        
        let conFile = self.applyCOD.applyCodFiles[indexPath.item]
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
        }else if conFile.imageType == CODImageType.businessImage {
            if conFile.image != nil {
                cell.imageView.image = conFile.image
            }else {
                if self.applyCOD.applyCodFiles[indexPath.item].filepath == "" {
                    cell.businessOrIdView.isHidden = false
                    cell.businessOrIdLabel.text = kBusinessLicenseTitle
                    cell.businessOrIdImageView.image = UIImage(named: "icon_addBusinesslicense")

                }else {
                    cell.businessOrIdView.isHidden = true
                    setImage(cell: cell, indexPath: indexPath)
                }
            }
            cell.nameTextField.text = kBusinessLicenseTitle
            cell.nameTextField.isUserInteractionEnabled = false;
            cell.editImage.isHidden = true

        }else if conFile.imageType == CODImageType.idImage {
            if conFile.image != nil {
                cell.imageView.image = conFile.image
            }else {
                if self.applyCOD.applyCodFiles[indexPath.item].filepath == "" {
                    
                    cell.businessOrIdView.isHidden = false
                    cell.businessOrIdLabel.text = "Add ID"
                    cell.businessOrIdImageView.image = UIImage(named: "icon_addID")

                }else {
                    cell.businessOrIdView.isHidden = true
                    setImage(cell: cell, indexPath: indexPath)
                }
            }
            cell.nameTextField.text = "ID"
            cell.nameTextField.isUserInteractionEnabled = false;
            cell.editImage.isHidden = true
        }else {
            if conFile.image != nil {
                cell.imageView.image = conFile.image
            }else {
                setImage(cell: cell, indexPath: indexPath)
            }
            cell.editImage.isHidden = true
            cell.nameTextField.text = self.applyCOD.applyCodFiles[indexPath.item].filetitle
            cell.nameTextField.isUserInteractionEnabled = true;
            cell.editImage.isHidden = false
        }
        
        cell.editTitle = { title in
            if validString(title) != ""{
                if let codFile = cell.codFile {
                    self.applyCOD.updateCODNameById(validInt(codFile.fileid), title: validString(title), callback: { (data, error) in
                        self.applyCOD.getApplyCod()
                    })
                }
            }
        }

        cell.deleteButton.setBackgroundImage(UIImage(named: "icon_cod_delete"), for: UIControlState())
        
        if applyCOD.status != 1 {
            if conFile.imageType == CODImageType.addImage {
                cell.deleteButton.isHidden = true
            }else {
                if editButton.title == "Done" {
                    if conFile.filepath != "" {
                        cell.deleteButton.isHidden = false
                    }else {
                        cell.deleteButton.isHidden = true
                    }
                }else {
                    cell.deleteButton.isHidden = true
                }
            }
        } else {
            cell.deleteButton.isHidden = true
        }

        cell.item = indexPath.item
        cell.selectImage = { image in
            let codFile = cell.codFile
            self.applyCOD.deleteCODImageById(validInt(codFile?.fileid), callback: { (data, error) in
                self.applyCOD.getApplyCod()
            })
        }

        if self.applyCOD.status == 1 {
            cell.nameTextField.isUserInteractionEnabled = false;
        }

        return cell
        
    }
    
    func setImage(cell:SSTCODCell, indexPath:IndexPath){
        if indexPath.row == tagLoading {
            cell.imageView.setImageWithImage(fileUrl: self.applyCOD.applyCodFiles[indexPath.item].filepath, placeImage: imageLoading)
        }else {
            cell.imageView.setImage(fileUrl: self.applyCOD.applyCodFiles[indexPath.item].filepath, placeholder: kIcon_loading)
        }
    }
    
    func seeImage(_ oldIndexParth: IndexPath, codCells: [SSTCODCell]){

        var showViewCodFiles = [SSTApplyCodFile]()
        for showViewCodFile in self.applyCOD.applyCodFiles {
            if showViewCodFile.filepath != "" {
                showViewCodFiles.append(showViewCodFile)
            }
        }
        
        let vc = XTPhotoBrowserViewController()
        vc.codCells = codCells
        vc.shopsArray = showViewCodFiles
        vc.transitioningDelegate = animator
        vc.modalPresentationStyle = .custom
        vc.indexPath = oldIndexParth;
        
        animator.indexPath =  oldIndexParth
        animator.applyCodFiles = self.applyCOD.applyCodFiles
        animator.presentedDelegate = self
        animator.dismissedDelegate = vc
        present(vc, animated: true, completion: nil)
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
                var showViewCodFiles = [SSTApplyCodFile]()
                for showViewCodFile in self.applyCOD.applyCodFiles {
                    if showViewCodFile.filepath != "" {
                        showViewCodFiles.append(showViewCodFile)
                    }
                }
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
                vc.shopsArray = showViewCodFiles
                
                vc.transitioningDelegate = animator
                vc.modalPresentationStyle = .custom
                
                vc.indexPath = indexp;
                
                animator.indexPath =  oldIndexParth
                animator.applyCodFiles = self.applyCOD.applyCodFiles
                animator.presentedDelegate = self
                animator.dismissedDelegate = vc
                
                present(vc, animated: true, completion: nil)

            } else {
                if applyCOD.status != 1{
                     tagLoading = indexPath.row
                    self.choseCamera(1)
                }
            }
        } else {
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
                indexp = IndexPath(row: indexPath.row - 1, section: 0)
                codCells.remove(at: 0)
            }
            if self.applyCOD.applyCodFiles[0].filepath != "" && self.applyCOD.applyCodFiles[1].filepath != "" {
                indexp = indexPath
            }

            let vc = XTPhotoBrowserViewController()

            vc.transitioningDelegate = animator
            vc.modalPresentationStyle = .custom

            var showViewCodFiles = [SSTApplyCodFile]()
            for showViewCodFile in self.applyCOD.applyCodFiles {
                if showViewCodFile.filepath != "" {
                    showViewCodFiles.append(showViewCodFile)
                }
            }
            
            vc.shopsArray = showViewCodFiles
            vc.indexPath = indexp;
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
    
    fileprivate func openCamera() {
        if  isCanUseCamera() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickVC.sourceType = .camera
                self.present(pickVC, animated: true, completion: nil)
            } else {
                SSTToastView.showError(kCODOpenCameraFailedText)
            }

        }else {
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
    
    fileprivate func openPhotoLibrary(_ maxSelectedCount:Int) {
        
        if  isCanUseCamera() {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                pickVC.sourceType = .photoLibrary
                self.present(pickVC, animated: true, completion: nil)
            } else {
                SSTToastView.showError(kCODOpenCameraInvaliddText)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if self.applyCOD.status != nil{
            if self.applyCOD.status == -1 {
                return CGSize(width: kScreenWidth, height: appForCODViewHeight)
            }else{
                if self.applyCOD.status == 0 { //审核中
                    return CGSize(width: kScreenWidth, height: 105)
                }else if self.applyCOD.status == 1 {  // 审核通过
                    return CGSize(width: kScreenWidth, height: auditViewHeight)
                }else if self.applyCOD.status == 2{  // 审核失败
                    return CGSize(width: kScreenWidth, height: failHeight)
                }else {
                    return CGSize.zero
                }
            }
        }else {
            return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var headView = UICollectionReusableView()
        headView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBlankHeaderView, for: indexPath) as! SSTBlankHeaderView
        if self.applyCOD.status != nil{
            if kind == UICollectionElementKindSectionHeader {
                if self.applyCOD.status == -1 {
                    headView.addSubview(appForCOD)
                }else{
                    if self.applyCOD.status == 0 { //审核中
                        headView.addSubview(auditView)
                    }else if self.applyCOD.status == 1 {  // 审核通过
                        headView.addSubview(appForCODFail)
                    }else if self.applyCOD.status == 2{  // 审核失败
                        headView.addSubview(appForCODFail)
                    }
                }
            }
        }
        return headView
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
    
    func removeAddImage(){
        
        let includeAddImage = self.applyCOD.applyCodFiles.contains { (codFile) -> Bool in
            if codFile.imageType == self.addCodFile.imageType {
                return true
            }else {
                return false
            }
        }
        if includeAddImage == true {
            self.applyCOD.applyCodFiles.removeLast()
        }
    }
}

//MARK:-- imagePicker delegate
extension SSTCODVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let typeStr = info[UIImagePickerControllerMediaType] as? String {
            if typeStr == "public.image" {
                
                let image = info[UIImagePickerControllerOriginalImage] as! UIImage
                imageLoading = image
                //弹窗，填写title226
                let bgView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
                bgView.backgroundColor = RGBA(211, g: 211, b: 211, a: 1)
                bgView.alpha = 0.5
                
                let imageTitleView =  loadNib("SSTImageTitle") as! SSTImageTitle  //未提交
                imageTitleView.frame = CGRect(x: 80*kProkScreenWidth, y: (kScreenHeight - 246)/2-80, width: kScreenWidth - 160*kProkScreenWidth, height: 226)
                imageTitleView.imageView.image = image
                imageTitleView.imageType = self.CODCellNow.codFile.imageType
                if self.CODCellNow.codFile.imageType == .businessImage {
                    imageTitleView.textField.text = kBusinessLicenseTitle
                    imageTitleView.textField.isUserInteractionEnabled = false;
                }
                if self.CODCellNow.codFile.imageType == .idImage {
                    imageTitleView.textField.text = kID
                    imageTitleView.textField.isUserInteractionEnabled = false
                }else {
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
        SSTProgressHUD.show(view: self.view)
        if self.CODCellNow.codFile.imageType != .addImage {
            let conFile = self.CODCellNow.codFile
            conFile?.filetitle = title
            conFile?.image = image
            if conFile?.fileid != nil {
                //删除 图片
                self.applyCOD.deleteCODImageById(validInt(conFile?.fileid), callback: { (data, error) in
                    // 上传图片
                    self.applyCOD.uploadCODImage(image, title:title, callback: { (data, error) in
                        if error == nil {
                            SSTToastView.showSucceed(kCODUploadImageSuccessText)
                            self.applyCOD.getApplyCod()
                        } else {
                            SSTToastView.showError(kCODUploadImageFailedText)
                        }
                    })
                })
            }else {
                // 上传图片
                self.applyCOD.uploadCODImage(image, title:title, callback: { (data, error) in
                    if error == nil {
                        SSTToastView.showSucceed(kCODUploadImageSuccessText)
                        self.applyCOD.getApplyCod()
                    } else {
                        SSTToastView.showError(kCODUploadImageFailedText)
                    }
                })
            }
        }else {
            //创建一个新的对象
            let codFile = SSTApplyCodFile()
            codFile.filetitle = title
            codFile.image = image
            self.applyCOD.applyCodFiles.insert(codFile, at: self.applyCOD.applyCodFiles.count - 1)
            if self.applyCOD.applyCodFiles.count > 6 {
                self.removeAddImage()
            }
            // 上传图片
            self.applyCOD.uploadCODImage(image, title:title, callback: { (data, error) in
                if error == nil {
                    SSTToastView.showSucceed(kCODUploadImageSuccessText)
                    self.applyCOD.getApplyCod()
                } else {
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

extension SSTCODVC: SSTUIRefreshDelegate {
    func refreshUI(_ data: Any?) {
        SSTProgressHUD.dismiss(view: self.view)
        imageViewArray.removeAll()
        // 未提交
        if self.applyCOD.status == -1 {
            appForCOD.isHidden = false
            auditView.isHidden = true
            appForCODFail.isHidden = true
           self.navigationItem.rightBarButtonItem = editButton
            
            appForCOD.titleLabel.text = kSSTCODInvalidTitle
            appForCOD.contentLabel.text = kSSTCODInvalidContent
            self.insertAddImage()
        }else{
            if self.applyCOD.status == 0 { //审核中
                self.navigationItem.rightBarButtonItem = editButton
                auditView.isHidden = false
                appForCOD.isHidden = true
                appForCODFail.isHidden = true

                auditView.titleLabel.text = kSSTCODDeniedTitle
                auditView.contentLabel.text = kSSTCODDeniedContent
                self.insertAddImage()
            }else if self.applyCOD.status == 1 {  // 审核通过
                 self.navigationItem.rightBarButtonItem = UIBarButtonItem()
                auditView.isHidden = true
                appForCOD.isHidden = true
                appForCODFail.isHidden = false
                
                appForCODFail.iconImge.image = UIImage(named: "icon_select_sel")
                appForCODFail.titleLabel.text = kSSTCODApprovedTitle
                appForCODFail.contentLabel.text = kSSTCODApprovedContent
                appForCODFail.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: auditViewHeight)
            }else if self.applyCOD.status == 2{  // 审核失败
                self.navigationItem.rightBarButtonItem = editButton
                auditView.isHidden = true
                appForCOD.isHidden = true
                appForCODFail.isHidden = false
                
                appForCODFail.iconImge.image = UIImage(named: "icon_more_cod_fail")
                appForCODFail.titleLabel.text = kSSTCODRejectedTitle
                appForCODFail.contentLabel.text = self.applyCOD.denyreason

                let appForCODFailtitleHegiht = kSSTCODRejectedTitle.sizeByWidth(font: 15, width: kScreenWidth - 135).height
                let appForCODFailcontentHegiht = self.applyCOD.denyreason.sizeByWidth(font: 13, width: kScreenWidth - 135).height
                failHeight = appForCODFailtitleHegiht + appForCODFailcontentHegiht + 47
                appForCODFail.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: failHeight)
                
                self.insertAddImage()
            }
        }
        collectionView.reloadData()
    }
}

extension SSTCODVC : AnimatorPresentedDelegate {
    
    func startRect(_ indexPath: IndexPath) -> CGRect {
        
        guard let cell = collectionView?.cellForItem(at: indexPath) else {
            return CGRect.zero
        }
        let cellFrame  = cell.frame
        let startRect = collectionView.convert(cellFrame, to: UIApplication.shared.keyWindow)
        return startRect
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




