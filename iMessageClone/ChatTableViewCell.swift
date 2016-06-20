//
//  ChatTableViewCell.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/19/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseStorage

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageText: UILabel!
    
    override func awakeFromNib() {
        profileImageView.layer.cornerRadius = profileImageView.frame.size.height / 2
        profileImageView.clipsToBounds = true
    }
    
    func configureCell(idUser: String, message: [String: AnyObject]) {
        self.messageText.text = message["message"] as? String
        DataService.dataService.USER_REF.child(idUser).observeEventType(.Value, withBlock: {snapshot in
            let dict = snapshot.value as! [String: AnyObject]
            let imageURL = dict["profileImage"] as! String
            if imageURL.hasPrefix("gs://") {
                FIRStorage.storage().referenceForURL(imageURL).dataWithMaxSize(INT64_MAX) { (data, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    self.profileImageView.image = UIImage.init(data: data!)
                }
            } else if let url = NSURL(string: imageURL), let data = NSData(contentsOfURL: url) {
                self.profileImageView.image = UIImage.init(data: data)
            }
        })
    }
    
    
}
