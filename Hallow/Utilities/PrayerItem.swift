//
//  PrayerItem.swift
//  Hallow
//
//  Created by Alex Jones on 5/16/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class PrayerItem: Object {
    @objc dynamic var title = "Day 1"
    @objc dynamic var desc = "Sitting in silence"
    @objc dynamic var desc2 = "Placeholder"
    @objc dynamic var audioURLPath = "audio/Meditation - 10 mins - F - 1.mp3"
    @objc dynamic var length = "10 mins"
    @objc dynamic var guide = "Francis"
    
    convenience init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let title = data["title"] as? String,
            let desc = data["description"] as? String,
            let desc2 = data["description2"] as? String,
            let audioFilePath = data["audio"] as? String,
            let guide = data["guide"] as? String,
            let length = data["length"] as? String else {
                fatalError("This prayer document could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.init()

        self.title = title
        self.desc = desc
        self.desc2 = desc2
        self.audioURLPath = audioFilePath
        self.length = length
        self.guide = guide
    }
}
