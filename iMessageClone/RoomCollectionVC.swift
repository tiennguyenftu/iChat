//
//  RoomCollectionVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import JSQMessagesViewController

private let CELL_IDENTIFIER = "ChatRoomCell"

class RoomCollectionVC: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var rooms = [Room]()
    
    var jsqChatVC: JSQChatVC!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataService.dataService.fetchRoomDataFromServer { (room) in
            self.rooms.append(room)
            let indexPath = NSIndexPath(forItem: self.rooms.count - 1, inSection: 0)
            self.collectionView?.insertItemsAtIndexPaths([indexPath])
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
       
        if let user = DataService.dataService.currentUser {
            guard let photoURL = user.photoURL else {
                print("Error")
                return
            }
            DataService.dataService.getUserProfileImageFromServerWithPath("\(photoURL)")
        }
    }
    
    @IBAction func showActionSheet(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: "Select", message: "", preferredStyle: .ActionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { _ in
            print("Cancelled")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Edit Profile", style: .Default) { (action) in
            let profileVC = self.storyboard?.instantiateViewControllerWithIdentifier("EditProfile") as! UITableViewController
            self.navigationController?.pushViewController(profileVC, animated: true)
        })
        
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .Default) { (action) in
            print("Logged Out")
            self.logOutTapped()
        })
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func logOutTapped() {
        DataService.dataService.logOut()
    }

    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showJSQChatVC" {
            let cell = sender as! RoomCollectionViewCell
            let indexPath = collectionView?.indexPathForCell(cell)
            let room = rooms[indexPath!.row]
            jsqChatVC = segue.destinationViewController as! JSQChatVC
            jsqChatVC.roomID = room.id
            
            if let user = DataService.dataService.currentUser {
                jsqChatVC.senderId = user.uid
                jsqChatVC.senderDisplayName = user.displayName
                
            
            }

        }
    }
    
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((view.frame.width - 10.0) / 2.0, (view.frame.width - 10.0) / 2.0)
    }

    // MARK: UICollectionViewDataSource


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CELL_IDENTIFIER, forIndexPath: indexPath) as? RoomCollectionViewCell {
            cell.configureCell(rooms[indexPath.row])
            return cell
        }
    
        return RoomCollectionViewCell()
    }

}
