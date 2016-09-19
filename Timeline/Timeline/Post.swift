//
//  Post.swift
//  Timeline
//
//  Created by Justin Carver on 9/12/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Post: SearchableRecord, CloudKitSyncable {
    
    static let kPost = "Post"
    static let kTimeStamp = "timeStamp"
    static let kPhotoData = "photoData"
    
    var comments: [Comment]
    var timeStamp: NSDate
    
    var recordType: String {
        return Post.kPost
    }
    
    // MARK: - CloudKit
    
    var cloudKitRecordID: CKRecordID?
    
    func matchesSearchTerm(searchTerm: String) -> Bool {
        let matchComments = comments.filter { $0.text.lowercaseString.containsString(searchTerm.lowercaseString) }
        return !matchComments.isEmpty
    }
    
    private var temporaryPhotoURL: NSURL {
        
        let temporaryDirectory = NSTemporaryDirectory()
        let temporaryDirectoryURL = NSURL(fileURLWithPath: temporaryDirectory)
        guard let fileURL = temporaryDirectoryURL.URLByAppendingPathComponent(NSUUID().UUIDString)!.URLByAppendingPathExtension("jpg") else { return NSURL() }
        
        imageData?.writeToURL(fileURL, atomically: true)
        
        return fileURL
    }
    
    // MARK: - Image
    
    var imageData: NSData?
    var photo: UIImage? {
        guard let data = imageData, let image = UIImage(data: data) else { return nil }
        return image
    }
    
    // MARK: - Initializers
    
    init(comments: [Comment] = [], imageData: NSData?, timeStamp: NSDate = NSDate()) {
        self.comments = comments
        self.imageData = imageData
        self.timeStamp = timeStamp
    }
    
    convenience required init?(record: CKRecord) {
        
        guard let timeStamp = record.creationDate, photo = record[Post.kPhotoData] as? CKAsset else { return nil }
        
        let photoData = NSData(contentsOfURL: photo.fileURL)
        self.init(imageData: photoData, timeStamp: timeStamp)
        cloudKitRecordID = record.recordID
    }
}

// MARK: -

extension CKRecord {
    convenience init(post: Post) {
        let recordID = CKRecordID(recordName: NSUUID().UUIDString)
        self.init(recordType: post.recordType, recordID: recordID)
        
        self[Post.kTimeStamp] = post.timeStamp
        self[Post.kPhotoData] = CKAsset(fileURL: post.temporaryPhotoURL)
    }
}
