//
//  Room.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import Foundation

class Room {
    var id: String!
    var caption: String!
    var thumbnail: String!
    
    init(key: String, snapshot: [String: AnyObject]) {
        self.id = key
        self.caption = snapshot["caption"] as! String
        self.thumbnail = snapshot["fileUrl"] as! String
    }
}