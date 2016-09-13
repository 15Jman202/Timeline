//
//  Comment.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation

class Comment {
    
    var text: String
    var timeStamp: NSDate
    var post: Post
    
    init(text: String, timeStamp: NSDate = NSDate(), post: Post) {
        self.text = text
        self.timeStamp = timeStamp
        self.post = post
    }
}
