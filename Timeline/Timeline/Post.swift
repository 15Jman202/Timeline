//
//  Post.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation
import UIKit

class Post {
    
    var comments: [Comment]
    var imageData: NSData
    var photo: UIImage? {
        guard let image = UIImage(data: imageData) else { return nil }
        return image
    }
    
    var timeStamp: NSDate
    
    init(comments: [Comment] = [], imageData: NSData, timeStamp: NSDate = NSDate()) {
        self.comments = comments
        self.imageData = imageData
        self.timeStamp = timeStamp
    }
}

