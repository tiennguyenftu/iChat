//
//  LogInVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogInVC: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(LogInVC.dismissKeyboard(_:)))
        dismissKeyboardGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func logInTapped(sender: UIButton) {
        guard let email = emailTextField.text where !email.isEmpty, let password = passwordTextField.text where !password.isEmpty else {
            ProgressHUD.showError("Email & Password could not be empty")
            return
        }
        DataService.dataService.logIn(email, password: password)
    }
    
}


extension LogInVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
