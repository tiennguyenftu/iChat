//
//  JSQChatVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/19/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import FirebaseStorage

class JSQChatVC: JSQMessagesViewController {
    
    
    var roomID: String!
    var messages = [JSQMessage]()
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    
    var outgoingImage: UIImage!
    var incomingImage: [UIImage]!
    
    var profileImages =  [UIImage]()
    
    var imagePicker = UIImagePickerController()
    var imageToSent: UIImage!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Chat"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(JSQChatVC.reloadCollectionView))
        
        setupBubbles()
        
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
        
        keyboardController.textView.delegate = self
        let dismissKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(JSQChatVC.dismissKeyboard(_:)))
        dismissKeyboardGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(dismissKeyboardGesture)
        
        automaticallyScrollsToMostRecentMessage = true

        fetchData()
    }
    
    func fetchData() {
        DataService.dataService.fetchMessageFromServer(roomID) { (snapshot) in
            if let text = snapshot.value!["textMessage"] as? String, let senderID = snapshot.value!["senderID"] as? String {
                self.addMessage(senderID, text: text)
                self.finishSendingMessage()
            }
        }

    }
    
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        DataService.dataService.getAllUserProfiles()
    }
    
    func setupBubbles() {
        let factory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = factory.outgoingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = factory.incomingMessagesBubbleImageWithColor(
            UIColor.jsq_messageBubbleLightGrayColor())
    }
    
    
    func addMessage(id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message)
    }
    
    
    //MARK: - Data source
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
//        cell.avatarImageView.layer.cornerRadius = kJSQMessagesCollectionViewAvatarSizeDefault / 2
//        cell.avatarImageView.clipsToBounds = true
//        cell.avatarImageView.image = UIImage(named: "profileImage")
        
        
        if message.senderId == senderId {
            if let textView = cell.textView {
                textView.textColor = UIColor.whiteColor()
            }
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            return outgoingBubbleImageView
        } else {
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!,
                                 avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let avatar = JSQMessagesAvatarImage(avatarImage: nil, highlightedImage: nil, placeholderImage: UIImage(named: "profileImage"))
        let message = messages[indexPath.item]
        if message.senderId == senderId {
            avatar.avatarImage = outgoingImage
        } else {
            let imageData = DataService.dataService.allProfileImage[message.senderId]
            avatar.avatarImage = UIImage.init(data: imageData!)
        }
        
        return avatar
    }
    
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        DataService.dataService.createNewMessage(senderId, roomID: roomID, textMessage: text)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        print("Accessory Button Pressed")
        let actionSheet = UIAlertController(title: "Send", message: "", preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .Default) { action in
            self.choosePhoto()
        })
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func choosePhoto() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerController.isSourceTypeAvailable(.Camera) ? .Camera : .PhotoLibrary
        presentViewController(self.imagePicker, animated: true, completion: nil)
    }
    
    func sendPhoto() {
        let photoItem = JSQPhotoMediaItem(image: imageToSent)
        let message = JSQMessage.init(senderId: senderId, displayName: senderDisplayName, media: photoItem)
        messages.append(message)
        collectionView.reloadData()
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 10 == 0 {
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(messages[indexPath.item].date)
        }

        return nil
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 10 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }

        return 0
    }
    
    //MARK: - Text view delegate
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n"{
           textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func dismissKeyboard(tap: UITapGestureRecognizer) {
        view.endEditing(true)
    }

}


extension JSQChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageToSent = image
        sendPhoto()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}













