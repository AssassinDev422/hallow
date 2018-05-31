//
//  PrayerItem.swift
//  Hallow
//
//  Created by Alex Jones on 5/16/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class PrayerItem {
    var title = "Day 1"
    var description = "Sitting in silence"
    var audioURLPath = "audio/day_1.mp3"
    var length = "10 mins"
    
    init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let title = data["title"] as? String,
            let description = data["description"] as? String,
            let audioFilePath = data["audio"] as? String,
            let length = data["length"] as? String else {
                fatalError("This prayer document could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.title = title
        self.description = description
        self.audioURLPath = audioFilePath
        self.length = length
    }
}
