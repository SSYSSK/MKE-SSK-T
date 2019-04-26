//
//  SSTCODCell.swift
//  sst-ios
//
//  Created by MuChao Ke on 16/11/18.
//  Copyright © 2016年 SST. All rights reserved.
//

import UIKit

class SSTCODCell: UICollectionViewCell {

    @IBOutlet weak var businessOrIdView: UIView!
    @IBOutlet weak var businessOrIdImageView: UIImageView!
    @IBOutlet weak var businessOrIdLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var editImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLead: NSLayoutConstraint!
    @IBOutlet weak var imageTrailing: NSLayoutConstraint!
    
    var codFile: SSTApplyCodFile!
    
    var selectImage: ((_ item: UIImage?) -> Void)?
    var editTitle: ((_ title: String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.masksToBounds = true;
        imageView.layer.cornerRadius = 5 //变圆形
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = RGBA(111, g: 115, b: 245, a: 1).cgColor
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        
        nameTextField.delegate = self
        
        businessOrIdView.layer.masksToBounds = true
        businessOrIdView.layer.cornerRadius = 5 //变圆形
        businessOrIdView.layer.borderWidth = 0.5
        businessOrIdView.layer.borderColor = RGBA(111, g: 115, b: 245, a: 1).cgColor
        businessOrIdView.contentMode = UIViewContentMode.scaleAspectFill
    }

    @IBAction func deleteEvent(_ sender: AnyObject) {
        self.selectImage?(imageView.image)
    }
    
    var item: Int = 0 {
        didSet {
            if item % 2 == 0 {
                imageLead.constant = 14
                imageTrailing.constant = 7
            } else {
                imageLead.constant = 7
                imageTrailing.constant = 14
            }
        }
    }
    
    @IBAction func editEvent(_ sender: AnyObject) {
        
    }
}

// MARK: -- textField delegate

extension SSTCODCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.editTitle?(textField.text)
        textField.resignFirstResponder()
        return true
    }
}
