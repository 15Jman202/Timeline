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
    
    // MARK: - Properties
    
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
                nc.postNotificationName(PostController.PostCommentsChangedNotification, object: self)
            })
        }
    }
    
    // MARK: - CRUD
    
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
    
    // MARK: - Syncing
    
    var isSyncing: Bool = false
    
    func preformFullSync(completion: (() -> Void)? = nil) {
        
        guard isSyncing == false else { return }
        
        isSyncing = true
        
        pushChangesToCloud { (success) in
            self.fetchNewPosts(Post.kPost) {
                self.fetchNewPosts(Comment.kComment) {
                    self.isSyncing = false
                    if let completion = completion {
                        completion()
                    }
                }
            }
        }
    }
    
    
    // MARK: - CloudKit
    
    private func recordsOfType(type: String) -> [CloudKitSyncable] {
        switch type {
        case "Post":
            return posts.flatMap { $0 as CloudKitSyncable }
        case "Comment":
            return comments.flatMap { $0 as CloudKitSyncable }
        default:
            return []
        }
    }
    
    func syncedRecords(type: String) -> [CloudKitSyncable] {
        return recordsOfType(type).filter { $0.isSynced }
    }
    
    func unsyncedRecords(type: String) -> [CloudKitSyncable] {
        return recordsOfType(type).filter { !$0.isSynced }
    }
    
    func fetchNewPosts(type: String, completion: (() -> Void)?) {
        let gotReferences = self.syncedRecords(type).flatMap {$0.cloudKitReference}
        var predicate = NSPredicate(format: "NOT(recordID IN %@)", argumentArray: [gotReferences])
        
        if gotReferences.isEmpty {
            predicate = NSPredicate(value: true)
        }
        
        PostController.cloudKitManager.fetchRecordsWithType(type, predicate: predicate, recordFetchedBlock: { (record) in
            
            if type == Post.kPost {
                if let post = Post(record: record) {
                    self.posts.append(post)
                }
            } else if type == Comment.kComment {
                if let comment = Comment(record: record), let postReference = record[Comment.kPost] as? CKReference, let postIndex = self.posts.indexOf({ $0.cloudKitRecordID == postReference.recordID }){
                        let post = self.posts[postIndex]
                        post.comments.append(comment)
                        comment.post = post
                }
                
            } else {
                print("Error: Type must be either of type Post or Comment")
            }
            
            }) { (records, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    print("Error fetching CloudKit Records")
                }
                completion?()
        }
    }
    
    func pushChangesToCloud(success: ((success: Bool, error: NSError?) -> Void)) {
        let unsavedPosts = unsyncedRecords(Post.kPost) as? [Post] ?? []
        let unsavedComments = unsyncedRecords(Comment.kComment) as? [Comment] ?? []
        var unsyncedChanges = [CKRecord: CloudKitSyncable]()
        for post in unsavedPosts {
            let record = CKRecord(post: post)
            unsyncedChanges[record] = post
        }
        for comment in unsavedComments {
            let record = CKRecord(comment: comment)
            unsyncedChanges[record] = comment
        }
        
        let unsavedRecords = Array(unsyncedChanges.keys)
        
        PostController.cloudKitManager.saveRecords(unsavedRecords, perRecordCompletion: { (record, error) in
            
            guard let record = record else { return }
            unsyncedChanges[record]?.cloudKitRecordID = record.recordID
            
        }) { (records, error) in
            if error != nil {
                print("Error Saving Unsaved Data to CloudKit")
                success(success: false, error: error)
            }
            success(success: true, error: nil)
        }
    }
}
    
    
    
    
    
    
    

