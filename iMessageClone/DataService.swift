//
//  DataService.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import Foundation
import Firebase

let roomRef = FIRDatabase.database().reference()

class DataService {
    
    static let dataService = DataService()
    
    private var _BASE_REF = roomRef
    private var _ROOM_REF = roomRef.child("rooms")
    private var _MESSAGE_REF = roomRef.child("messages")
    private var _USERS_REF = roomRef.child("users")
    
    var BASE_REF: FIRDatabaseReference {
        return _BASE_REF
    }
    
    var ROOM_REF: FIRDatabaseReference {
        return _ROOM_REF
    }
    
    var MESSAGE_REF: FIRDatabaseReference {
        return _MESSAGE_REF
    }
    
    var USER_REF: FIRDatabaseReference {
        return _USERS_REF
    }
    
    var currentUser: FIRUser? {
        return (FIRAuth.auth()?.currentUser)!
    }
    
    var storageRef: FIRStorageReference {
        return FIRStorage.storage().reference()
    }
    
    var fileUrl: String!
    
    var profileImage: UIImage?
    var allProfileImage = [String: NSData]()
    
    //MARK: - Authentication
    
    //Sign up
    
    func SignUpWithUsername(username: String, email: String, password: String, data: NSData) {
        FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
            if let error  = error {
                print(error.localizedDescription)
                return
            }
            
            ProgressHUD.show("Signing Up...")
            
            let changeRequest = user?.profileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChangesWithCompletion { (error) in
                if let error  = error {
                    print(error.localizedDescription)
                    return
                }
                
                let filePath = "profileImage/\(user!.uid)"
                let metadata = FIRStorageMetadata()
                metadata.contentType = "image/jpeg"
                
                self.storageRef.child(filePath).putData(data, metadata: metadata) { (metadata, error) in
                    if let error  = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    self.fileUrl = metadata?.downloadURLs![0].absoluteString
                    let changeRequestPhoto = user?.profileChangeRequest()
                    changeRequestPhoto?.photoURL = NSURL(string: filePath)
                    changeRequestPhoto?.commitChangesWithCompletion { (error) in
                        if let error  = error {
                            print(error.localizedDescription)
                            return
                        } else {
                            print("Profile created")
                        }
                    }
                    
                    self.USER_REF.child(user!.uid).setValue(["userId": user!.uid,"username": username, "email": email, "profileImage": self.storageRef.child(metadata!.path!).description])
                    (UIApplication.sharedApplication().delegate as! AppDelegate).logIn()
                }
            }
        }
    }
    
    //Update profile
    
    func updateProfile(username: String, email: String, data: NSData) {
        
        currentUser!.updateEmail(email) { (error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Email updated!")
            }
        }
        
        let filePath = "\(currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate()))"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.child(filePath).putData(data, metadata: metadata) { (metadata, error) in
            if let error  = error {
                print(error.localizedDescription)
                return
            }
            
            self.fileUrl = metadata?.downloadURLs![0].absoluteString
            let changeRequestProfile = self.currentUser?.profileChangeRequest()
            changeRequestProfile?.photoURL = NSURL(string: filePath)
            changeRequestProfile?.displayName = username
            changeRequestProfile?.commitChangesWithCompletion { (error) in
                if let error  = error {
                    print(error.localizedDescription)
                    return
                } else {
                    print("Profile updated")
                    
                }
            }
            
            
            ProgressHUD.showSuccess("Saved!")
        }
        
    }
    
    //Log in
    
    func logIn(email: String, password: String) {
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            ProgressHUD.show("Signing In...")
            (UIApplication.sharedApplication().delegate as! AppDelegate).logIn()
        }
    }
    
    //Log out
    
    func logOut() {
        do {
            try FIRAuth.auth()?.signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let logInVC = storyboard.instantiateViewControllerWithIdentifier("LoginVC") as! LogInVC
            UIApplication.sharedApplication().keyWindow?.rootViewController = logInVC
        } catch let error as NSError {
            print("Sign Out Error: \(error.localizedDescription)")
        }
    }
    
    //MARK: - User
    
    //Get profile image
    
//    func getUserProfileImage() {
//        if let user = DataService.dataService.currentUser {
//            DataService.dataService.USER_REF.child(user.uid).observeEventType(.Value, withBlock: {snapshot in
//                
//                let dict = snapshot.value as! [String: AnyObject]
//                let imageURL = dict["profileImage"] as! String
//                if imageURL.hasPrefix("gs://") {
//                    FIRStorage.storage().referenceForURL(imageURL).dataWithMaxSize(INT64_MAX) { (data, error) in
//                        if let error = error {
//                            print(error.localizedDescription)
//                            return
//                        }
//                        self.profileImage = UIImage.init(data: data!)
//                        print("1. Profile Image")
//                    }
//                } else if let url = NSURL(string: imageURL), let data = NSData(contentsOfURL: url) {
//                    self.profileImage = UIImage.init(data: data)
//                    print("2. Profile Image")
//                }
//            })
//        }
//
//    }
    

    
    func getUserProfileImageFromServerWithPath(path: String) {
        storageRef.child(path).dataWithMaxSize(INT64_MAX) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.profileImage = UIImage.init(data: data!)
        }
        
    }
    
    func getAllUserProfiles () {
        MESSAGE_REF.observeEventType(.Value, withBlock: {snapshot in
            let dict = snapshot.value as! [String: AnyObject]
            for (_, value) in dict {
                let userInfo = value as! [String: String]
                let senderID: String! = userInfo["senderID"]
                FIRStorage.storage().referenceForURL("gs://imessageclone.appspot.com/profileImage/\(senderID)").dataWithMaxSize(INT64_MAX) { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.allProfileImage[senderID] = data
                }
                
            }
            
        })
    }

    //MARK: - Room
    
    func createNewRoom(user: FIRUser, caption: String, data: NSData) {
        let filePath = "\(user.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate()))"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.child(filePath).putData(data, metadata: metadata) { (metadata, error) in
            if let error  = error {
                print(error.localizedDescription)
                return
            }
            
            self.fileUrl = metadata?.downloadURLs![0].absoluteString
            if FIRAuth.auth()?.currentUser != nil {
                let idRoom = self.BASE_REF.child("rooms").childByAutoId()
                idRoom.setValue(["caption": caption, "thummnailUrlFromStorage": self.storageRef.child((metadata?.path)!).description, "fileUrl": self.fileUrl])
            }
        }
    }
    
    func fetchRoomDataFromServer(callback: (Room) -> ()) {
        DataService.dataService.ROOM_REF.observeEventType(.ChildAdded, withBlock: { (snapshot) in
            let room = Room(key: snapshot.key, snapshot: snapshot.value as! [String: AnyObject])
            callback(room)
        })
    }
    
    
    //MARK: - Message
    func createNewMessage(userID: String, roomID: String, textMessage: String) {
        let idMessage = roomRef.child("messages").childByAutoId()
        MESSAGE_REF.child(idMessage.key).setValue(["senderID": userID, "textMessage": textMessage])
        ROOM_REF.child(roomID).child("messages").child(idMessage.key).setValue(true)
    }
    
    
    func fetchMessageFromServer(roomID: String, callback: (FIRDataSnapshot) -> ()) {
        ROOM_REF.child(roomID).child("messages").observeEventType(.ChildAdded, withBlock: {snapshot in
            self.MESSAGE_REF.child(snapshot.key).observeEventType(.Value, withBlock: { snap in
                callback(snap)
            })
        })
    }
    
}
