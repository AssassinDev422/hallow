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
    @objc dynamic var docID: String = ""
    @objc dynamic var date: String = ""
    @objc dynamic var dateStored: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var entry: String = ""
    @objc dynamic var prayerTitle: String = "Day 1"

    convenience init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let date = data["Date"] as? String,
            let dateStored = data["Date Stored"] as? Date,
            let prayerTitle = data["Prayer Title"] as? String,
            let entry = data["Entry"] as? String else {
                print("FIREBASE: This journal entry could not be parsed. It's data was: \(document.data() ?? [:])")
                self.init()
                return
        }
        self.init()
        self.docID = document.documentID
        self.date = date
        self.dateStored = dateStored
        self.entry = entry
        self.prayerTitle = prayerTitle
    }
}
