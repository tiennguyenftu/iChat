//
//  SignUpVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.dismissKeyboard(_:)))
        dismissKeyboardGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboardGesture)
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpVC.selectPhoto(_:)))
        tapGesture.numberOfTapsRequired = 1
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.height / 2.0
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
    
    @IBAction func cancelTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUpTapped(sender: UIButton) {
        guard let username = usernameTextField.text where !username.isEmpty, let email = emailTextField.text where !email.isEmpty, let password = passwordTextField.text where !password.isEmpty else {
            return
        }
        
        let data = UIImageJPEGRepresentation(profileImageView.image!, 0.1)
        DataService.dataService.SignUpWithUsername(username, email: email, password: password, data: data!)

    }

}

extension SignUpVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        profileImageView.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension SignUpVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}



