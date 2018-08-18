//
//  JournalEntry.swift
//  Hallow
//
//  Created by Alex Jones on 7/26/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class JournalEntry: Object {
    @objc dynamic var userEmail: String = ""
    @objc dynamic var docID: Int = 0
    @objc dynamic var date: String = ""
    @objc dynamic var dateStored: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var entry: String = ""
    @objc dynamic var prayerTitle: String = "Day 1"
    
    override static func primaryKey() -> String? {
        return "docID"
    }
}
