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
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var dateStored: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var _guide: String = "Francis"
    @objc dynamic var isFirstDay: Bool = false
    @objc dynamic var isLoggedIn: Bool = false
    @objc dynamic var timeInPrayer = 0.00
    @objc dynamic var streak = 1
    @objc dynamic var _completedPrayers: String = ""
    @objc dynamic var mostRecentPrayerDate: Date = Date(timeIntervalSince1970: 0)
    @objc dynamic var nextPrayerIndex: Int = 1
    
    var completedPrayers: [String] {
        get {
            return _completedPrayers.components(separatedBy: ",")
        } set {
            _completedPrayers = newValue.joined(separator: ",")
        }
    }
    
    enum Guide: String {
        case abby = "Abby"
        case francis = "Francis"
    }
    var guide: Guide {
        get {
            guard let rawValue = Guide(rawValue: _guide) else {
                print("Error in guide enum conversion")
                return Guide.francis
            }
            return rawValue
        } set {
            _guide = newValue.rawValue
        }
    }
    
    convenience init(firestoreDocument document: DocumentSnapshot) {
        guard let data = document.data(),
            let name = data["Name"] as? String,
            let email = data["Email"] as? String,
            let dateStored = data["Date Stored"] as? Date,
            let isFirstDay = data["First Day"] as? Bool,
            let isLoggedIn = data["Logged In"] as? Bool,
            let timeInPrayer = data["Time in Prayer"] as? Double,
            let streak = data["Streak"] as? Int,
            let mostRecentPrayerDate = data["Most Recent Prayer Date"] as? Date,
            let _completedPrayers = data["Completed Prayers"] as? String,
            let _guide = data["Guide"] as? String,
            let nextPrayerIndex = data["Next Prayer Index"] as? Int else {
                print("FIREBASE: This user file could not be parsed. It's data was: \(document.data() ?? [:])") 
                self.init()
                return
        }
        self.init()
        self.name = name
        self.email = email
        self.dateStored = dateStored
        self.isFirstDay = isFirstDay
        self.isLoggedIn = isLoggedIn
        self.timeInPrayer = timeInPrayer
        self.streak = streak
        self.mostRecentPrayerDate = mostRecentPrayerDate
        self._completedPrayers = _completedPrayers
        self._guide = _guide
        self.nextPrayerIndex = nextPrayerIndex
    }
    
    static var current: User? {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("REALM: Error pulling realm stuff")
                return nil
            }
            return user
        } catch {
            print("REALM: Error accessing realm for user")
            return nil
        }
    }
    
    override static func primaryKey() -> String? {
        return "email"
    }
}
