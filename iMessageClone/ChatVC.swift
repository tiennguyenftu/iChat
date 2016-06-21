//
//  ChatVC.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ChatVC: UIViewController {
    
    struct CellIdentifier {
        static let cellIDMessageReceived = "YourMessageCell"
        static let cellIDMessageSent = "MyMessageCell"
    }
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var roomID: String!
    var messages = [FIRDataSnapshot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat Room"
        tableView.delegate = self
        tableView.dataSource = self
        
        DataService.dataService.fetchMessageFromServer(roomID) { (snap) in
            self.messages.append(snap)
            print(self.messages)
            self.tableView.reloadData()
        }
    }
    
    @IBAction func sendMessageTapped(sender: UIButton) {
        self.messageTextField.resignFirstResponder()
        if messageTextField.text != "" {
            if let user = FIRAuth.auth()?.currentUser {
//                DataService.dataService.createNewMessage(user.uid, roomID: roomID, textMessage: messageTextField.text!)
            } else {
                //No user signed in
            }
            messageTextField.text = nil
        } else {
            print("Empty String")
        }
    }
    
}

extension ChatVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let messageSnapshot = messages[indexPath.row]
        let message = messageSnapshot.value as! [String: AnyObject]
        let messageID = message["senderID"] as! String
        if messageID == DataService.dataService.currentUser?.uid {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.cellIDMessageSent, forIndexPath: indexPath) as! ChatTableViewCell
            cell.configureCell(messageID, message: message)
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier.cellIDMessageReceived, forIndexPath: indexPath) as! ChatTableViewCell
            cell.configureCell(messageID, message: message)
            return cell
        }
    }
}
