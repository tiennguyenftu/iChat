//
//  RoomCollectionViewCell.swift
//  iMessageClone
//
//  Created by Tien 95 on 6/18/16.
//  Copyright © 2016 Tien Nguyen. All rights reserved.
//

import UIKit
import FirebaseStorage

class RoomCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var roomThumbnail: UIImageView!
    @IBOutlet weak var roomCaption: UILabel!
    
    func configureCell(room: Room) {
        roomCaption.text = room.caption
        if let photoUrl = room.thumbnail {
            if photoUrl.hasPrefix("gs://") {
                FIRStorage.storage().referenceForURL(photoUrl).dataWithMaxSize(INT64_MAX) { (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    self.roomThumbnail.image = UIImage.init(data: data!)
                }
            } else if let url = NSURL(string: photoUrl), data = NSData(contentsOfURL: url) {
                self.roomThumbnail.image = UIImage.init(data: data)
            }
        }
    }
}
