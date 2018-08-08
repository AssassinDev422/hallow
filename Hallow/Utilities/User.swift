//
//  User.swift
//  Hallow
//
//  Created by Alex Jones on 5/22/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore
import UIKit
import RealmSwift

class User: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var dateStored: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var _guide: String = "Francis"
    enum Guide: String {
        case Abby = "Abby"
        case Francis = "Francis"
    }
    var guide: Guide {
        get {
            guard let rawValue = Guide(rawValue: _guide) else {
                print("Error in guide enum conversion")
                return Guide.Francis
            }
            return rawValue
        } set {
            _guide = newValue.rawValue
        }
    }
    @objc dynamic var isFirstDay: Bool = false
    @objc dynamic var isLoggedIn: Bool = false
    @objc dynamic var timeInPrayer = 0.00
    @objc dynamic var streak = 1
    @objc dynamic var _completedPrayers: String = ""
    var completedPrayers: [String] {
        get {
            return _completedPrayers.components(separatedBy: ",")
        } set {
            _completedPrayers = newValue.joined(separator: ",")
        }
    }
    @objc dynamic var mostRecentPrayerDate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var nextPrayerTitle: String = "Day 1"
    
    // Not stored on firebase but stored in realm
    @objc dynamic var pausedTime = 0.00

    convenience init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["Name"] as? String,
            let email = data["Email"] as? String,
            let dateStored = data["Date Stored"] as? Date,
            let _guide = data["Guide"] as? String,
            let isFirstDay = data["First Day"] as? Bool,
            let isLoggedIn = data["Logged In"] as? Bool,
            let timeInPrayer = data["Time in Prayer"] as? Double,
            let streak = data["Streak"] as? Int,
            let _completedPrayers = data["Completed Prayers"] as? String,
            let mostRecentPrayerDate = data["Most Recent Prayer Date"] as? Date,
            let nextPrayerTitle = data["Next Prayer Title"] as? String else {
                print("FIREBASE: This user file could not be parsed. It's data was: \(document.data() ?? [:])") 
                self.init()
                return
        }
        self.init()
        self.name = name
        self.email = email
        self.dateStored = dateStored
        self._guide = _guide
        self.isFirstDay = isFirstDay
        self.isLoggedIn = isLoggedIn
        self.timeInPrayer = timeInPrayer
        self.streak = streak
        self._completedPrayers = _completedPrayers
        self.mostRecentPrayerDate = mostRecentPrayerDate
        self.nextPrayerTitle = nextPrayerTitle
    }
}
