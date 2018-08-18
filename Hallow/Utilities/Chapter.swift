//
//  File.swift
//  Hallow
//
//  Created by Alex Jones on 8/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore
import RealmSwift

class Chapter: Object {
    @objc dynamic var name = "Joy"
    @objc dynamic var index = 0
    @objc dynamic var categoryIndex = 0
    @objc dynamic var desc = "Sitting in silence"
    @objc dynamic var avail = false
    
    convenience init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["Name"] as? String,
            let index = data["Index"] as? Int,
            let categoryIndex = data["Category Index"] as? Int,
            let desc = data["Description"] as? String,
            let avail = data["Available"] as? Bool else {
                fatalError("FIREBASE: This prayer document could not be parsed. It's data was: \(document.data() ?? [:])")
        }
        self.init()
        self.name = name
        self.index = index
        self.categoryIndex = categoryIndex
        self.desc = desc
        self.avail = avail
    }
    
    override static func primaryKey() -> String? {
        return "index"
    }
}
