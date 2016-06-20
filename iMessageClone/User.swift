//
//  User.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/20/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import Foundation

class User {
    var id: String!
    var username: String!
    var email: String
    var profileImage: String!
    
    init(key: String, snapshot: [String: AnyObject]) {
        self.id = key
        self.username = snapshot["username"] as! String
        self.email = snapshot["email"] as! String
        self.profileImage = snapshot["profileImage"] as! String
        
    }
    
}