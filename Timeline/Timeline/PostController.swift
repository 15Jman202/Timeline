//
//  PostController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation
import UIKit

class PostController {
    
    static let sharedController = PostController()
    
    var posts: [Post] = []
    
    func createPost(image: UIImage, text: String) -> Post? {
        guard let imageData: NSData = UIImagePNGRepresentation(image) else { return nil }
        let post = Post(imageData: imageData)
        addCommentToPost(text, post: post)
        return post
    }
    
    func addCommentToPost(text: String, post: Post) {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
    }
    
}
