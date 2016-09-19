//
//  PostController.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class PostController {
    
    //MARK: - Properties
    
    static let postChangedNotification = "PostsChangedNotification"
    static let PostCommentsChangedNotification = "PostCommentsChangedNotification"
    
    static let cloudKitManager = CloudKitManager()
    static let sharedController = PostController()
    
    var sortedPosts: [Post] {
        return posts.sort { return $0.timeStamp.compare($1.timeStamp) == .OrderedAscending }
    }
    
    var comments: [Comment] {
        return posts.flatMap { $0.comments }
    }
    
    var posts = [Post]() {
        didSet {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName(PostController.postChangedNotification, object: self)
            })
        }
    }
    
    //MARK: - CRUD
    
    func createPost(image: UIImage, text: String, completion: ((Post?) -> Void)?) {
        guard let imageData: NSData = UIImagePNGRepresentation(image) else { return }
        let post = Post(imageData: imageData)
        posts.append(post)
        let postRecord = CKRecord(post: post)
        let caption = addCommentToPost(text, post: post)
        let commentRecord = CKRecord(comment: caption)
        
        PostController.cloudKitManager.saveRecord(postRecord) { (record, error) in
            guard let record = record else {
                if error != nil {
                    print("Problem Saving to CloudKit: Error \(error?.localizedDescription)")
                }
                completion?(post)
                return
            }
            post.cloudKitRecordID = record.recordID
            
            PostController.cloudKitManager.saveRecord(commentRecord, completion: { (record, error) in
                guard let commentRecord = record else { return }
                if error != nil {
                    print("Error Saving Caption to CloutdKit: Error \(error?.localizedDescription)")
                }
                caption.cloudKitRecordID = commentRecord.recordID
                completion?(post)
            })
        }
    }
    
    func addCommentToPost(text: String, post: Post, completion: ((Comment) -> Void)? = nil) -> Comment {
        let comment = Comment(text: text, post: post)
        post.comments.append(comment)
        let commentRecord = CKRecord(comment: comment)
        PostController.cloudKitManager.saveRecord(commentRecord) { (record, error) in
            if error != nil {
                print("Problem Saving Comment to CloudKit: Error \(error?.localizedDescription)")
            }
            
            comment.cloudKitRecordID = record?.recordID
            completion?(comment)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let nc = NSNotificationCenter.defaultCenter()
                nc.postNotificationName(PostController.PostCommentsChangedNotification, object: post)
            })
        }
        
        return comment
    }
}
