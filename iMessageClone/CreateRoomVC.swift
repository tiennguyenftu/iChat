//
//  CreateRoomVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth

class CreateRoomVC: UIViewController {
    
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var roomPhoto: UIImageView!
    @IBOutlet weak var roomCaption: UITextField!
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        roomCaption.delegate = self
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(CreateRoomVC.dismissKeyboard(_:)))
        dismissKeyboardGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboardGesture)
    }
    
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func cancelDidTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func choosePhotoButtonTapped(sender: UIButton) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.Camera) ? .Camera : .PhotoLibrary
        presentViewController(imagePicker, animated: true, completion: nil)
        choosePhotoButton.setTitle("", forState: .Normal)
    }
    
    @IBAction func createRoomButtonTapped(sender: UIButton) {
        if roomPhoto.image == nil || roomCaption.text!.isEmpty {
            print("Thumbnail & Caption are required")
            return
        }
        let data = UIImageJPEGRepresentation(roomPhoto.image!, 0.1)
        DataService.dataService.createNewRoom((FIRAuth.auth()?.currentUser)!, caption: roomCaption.text!, data: data!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}

extension CreateRoomVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        roomPhoto.image = image
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension CreateRoomVC: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

