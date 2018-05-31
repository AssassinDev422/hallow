//
//  PrayerTracking.swift
//  Hallow
//
//  Created by Alex Jones on 5/24/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class PrayerTracking {
    var title: String
    var dateStored: String
    
    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let title = data["Prayer Title"] as? String,
            let dateStored = data["Date Stored"] as? String else {
                fatalError("This prayer tracking document could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.title = title
        self.dateStored = dateStored
    }
}
