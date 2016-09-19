//
//  Comment.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation
import CloudKit

class Comment: SearchableRecord, CloudKitSyncable {
    
    static let kComment = "Comment"
    static let kText = "text"
    static let kPost = "post"
    static let kTimeStamp = "timestamp"
    
    var text: String
    var timeStamp: NSDate
    var post: Post?
    
    // MARK: - CloudKit
    
    var recordType: String {
        return Comment.kComment
    }
    
    var cloudKitRecordID: CKRecordID?
    
    var cloudKitReference: CKReference?
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return text.lowercaseString.containsString(searchTerm.lowercaseString)
    }
    
    // MARK: - Initializers
    
    init(text: String, timeStamp: NSDate = NSDate(), post: Post?) {
        self.text = text
        self.timeStamp = timeStamp
        self.post = post
    }
    
    convenience required init?(record: CKRecord) {
        
        guard let timeStamp = record.creationDate, text = record[Comment.kText] as? String else { return nil }
        
        self.init(text: text, timeStamp: timeStamp, post: nil)
    }
}

extension CKRecord {
    convenience init(comment: Comment) {
        guard let post = comment.post else { fatalError("Comments must be related to a Post") }
        let postRecordID = post.cloudKitRecordID ?? CKRecord(post: post).recordID
        let recordID = CKRecordID(recordName: NSUUID().UUIDString)
        
        self.init(recordType: comment.recordType, recordID: recordID)
        
        self[Comment.kText] = comment.text
        self[Comment.kTimeStamp] = comment.timeStamp
        self[Comment.kPost] = CKReference(recordID: postRecordID, action: .DeleteSelf)
    }
}






