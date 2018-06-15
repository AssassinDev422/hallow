//
//  ConstantsItem.swift
//  Hallow
//
//  Created by Alex Jones on 6/15/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class ConstantsItem {
    
    var docID: String
    var dateStored: String
    var guide: String
    var isFirstDay: Bool
    var hasCompleted: Bool
    var hasSeenCompletionScreen: Bool
    var hasStartedListening: Bool
    var hasLoggedOutOnce: Bool
    
    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let dateStored = data["Date Stored"] as? String,
            let guide = data["guide"] as? String,
            let isFirstDay = data["isFirstDay"] as? Bool,
            let hasCompleted = data["hasCompleted"] as? Bool,
            let hasSeenCompletionScreen = data["hasSeenCompletionScreen"] as? Bool,
            let hasStartedListening = data["hasStartedListening"] as? Bool,
            let hasLoggedOutOnce = data["hasLoggedOutOnce"] as? Bool else {
                fatalError("This user file could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        
        self.docID = document.documentID
        self.dateStored = dateStored
        self.guide = guide
        self.isFirstDay = isFirstDay
        self.hasCompleted = hasCompleted
        self.hasSeenCompletionScreen = hasSeenCompletionScreen
        self.hasStartedListening = hasStartedListening
        self.hasLoggedOutOnce = hasLoggedOutOnce
    }
}
