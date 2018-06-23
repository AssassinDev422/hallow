//
//  StatsItem.swift
//  Hallow
//
//  Created by Alex Jones on 5/28/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class StatsItem {
    var timeInPrayer = 0.00
    var streak = 0
    var docID: String? = nil

    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let timeInPrayer = data["Time in Prayer"] as? Double,
            let streak = data["Streak"] as? Int else {
                fatalError("This prayer document could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.timeInPrayer = timeInPrayer
        self.streak = streak
        self.docID = document.documentID
    }
}
