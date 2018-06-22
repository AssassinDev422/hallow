//
//  LocalFirebaseData.swift
//  Hallow
//
//  Created by Alex Jones on 6/15/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation

class LocalFirebaseData {
    static var completedPrayers: [String] = []
    static var prayers: [PrayerItem] = []  //TODO: Have to pull in all lengths and guides etc.
    static var prayers10mins: [PrayerItem] = []
    static var prayers15mins: [PrayerItem] = []
    static var prayers5mins: [PrayerItem] = []
    
    static var nextPrayerTitle: String = "Day 1"
    
    static var name: String = ""
    static var timeTracker: Double = 0.00
    static var started: Int = 0
    static var completed: Int = 0
    static var mostRecentPrayerDate: Date = Date(timeIntervalSince1970: 0)
    static var streak: Int = 0
    
    static var statsDocID: String = ""
}
