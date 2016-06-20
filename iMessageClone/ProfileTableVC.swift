//
//  ProfileTableVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileTableVC: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        userNameTextField.delegate = self
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(LogInVC.dismissKeyboard(_:)))
        dismissKeyboardGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboardGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.selectPhoto(_:)))
        tapGesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.height / 2.0
        
        if let user = DataService.dataService.currentUser {
            emailTextField.text = user.email
            userNameTextField.text = user.displayName
            DataService.dataService.getUserProfileImageFromServerWithPath("\(user.photoURL)")
            profileImageView.image = DataService.dataService.profileImage
            
        } else {
            DataService.dataService.logOut()
        }
        
    }
    
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func selectPhoto(tap: UITapGestureRecognizer) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.Camera) ? .Camera : .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func saveTapped(sender: UIButton) {
        let data = UIImageJPEGRepresentation(profileImageView.image!, 0.1)
        ProgressHUD.show("Saving...")
        DataService.dataService.updateProfile(userNameTextField.text!, email: emailTextField.text!, data: data!)
    }
    

}

extension ProfileTableVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ProfileTableVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}