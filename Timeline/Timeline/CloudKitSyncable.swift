//
//  CloudKitSyncable.swift
//  Timeline
//
//  Created by Justin Carver on 9/15/16.
//  Copyright © 2016 Justin Carver. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    
    init?(record: CKRecord)
    
    var cloudKitRecordID: CKRecordID? { get set }
    var recordType: String { get }
}

extension CloudKitSyncable {
    var isSynced: Bool {
        if cloudKitRecordID != nil {
            return true
        } else {
            return false
        }
    }
    
    var cloudKitReference: CKReference? {
        guard let recordId = cloudKitRecordID else { return nil }
        let record = CKReference(recordID: recordId, action: .None)
        return record
    }
}
