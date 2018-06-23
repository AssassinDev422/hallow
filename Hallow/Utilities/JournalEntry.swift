//
//  JournalEntry.swift
//  Hallow
//
//  Created by Alex Jones on 5/16/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class JournalEntry {
    var docID: String
    var date: String
    var dateStored: String
    var entry: String
    var prayerTitle: String
    
    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let date = data["Date"] as? String,
            let dateStored = data["Date Stored"] as? String,
            let prayerTitle = data["Prayer Title"] as? String,
            let entry = data["Entry"] as? String else {
                fatalError("This journal entry could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.docID = document.documentID
        self.date = date
        self.prayerTitle = prayerTitle
        self.dateStored = dateStored
        self.entry = entry
    }
}
