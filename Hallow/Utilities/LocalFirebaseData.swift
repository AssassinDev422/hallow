//
//  LocalFirebaseData.swift
//  Hallow
//
//  Created by Alex Jones on 6/15/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import UIKit

class LocalFirebaseData {
    static var userEmail: String = ""
    
    static var completedPrayers: [String] = []
    static var lockedPrayers: [String] = ["Day 9+"]
        
    static var nextPrayerTitle: String = "Day 1"
    
    static var name: String = ""
    static var timeTracker: Double = 0.00
    static var started: Int = 0
    static var completed: Int = 0
    static var mostRecentPrayerDate: Date = Date(timeIntervalSince1970: 0)
    static var streak: Int = 0
    
    static var statsDocID: String = ""
    
    static var profilePicture: UIImage = #imageLiteral(resourceName: "profileWithCircle")
}
