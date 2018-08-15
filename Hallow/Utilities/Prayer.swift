//
//  Prayer.swift
//  Hallow
//
//  Created by Alex Jones on 5/16/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class Prayer: Object {
    @objc dynamic var name = "Not set"
    @objc dynamic var title = "Day 1"
    @objc dynamic var index = 0
    @objc dynamic var prayerIndex = 0
    @objc dynamic var chapterIndex = 0
    @objc dynamic var desc = "Sitting in silence"
    @objc dynamic var desc2 = "Placeholder"
    @objc dynamic var audioURLPath = "audio/Meditation - 10 mins - F - 1.mp3"
    @objc dynamic var length = "10 mins"
    @objc dynamic var guide = "Francis"
    
    convenience init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["Name"] as? String,
            let title = data["Title"] as? String,
            let index = data["Index"] as? Int,
            let prayerIndex = data["Prayer Index"] as? Int,
            let chapterIndex = data["Chapter Index"] as? Int,
            let desc = data["Description"] as? String,
            let desc2 = data["Description 2"] as? String,
            let guide = data["Guide"] as? String,
            let length = data["Length"] as? String,
            let audioFilePath = data["Audio"] as? String else {
                fatalError("FIREBASE: This prayer document could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.init()
        self.name = name
        self.title = title
        self.index = index
        self.prayerIndex = prayerIndex
        self.chapterIndex = chapterIndex
        self.desc = desc
        self.desc2 = desc2
        self.guide = guide
        self.length = length
        self.audioURLPath = audioFilePath
    }
}
