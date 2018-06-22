//
//  Constants.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation

class Constants {
    static var firebaseDocID: String = ""
    static var firstFirebaseDocID: String = ""
    
    static var guide: String = "Francis"
    static var isFirstDay: Bool = false
    static var hasCompleted: Bool = false
    static var hasSeenCompletionScreen: Bool = false
    static var hasStartedListening: Bool = false
    static var hasLoggedOutOnce: Bool = false
    
    // Don't have to change with user log in / out
    static var reminderTime: Date = Date(timeIntervalSince1970: 0)
    static var reminderSet: Bool = false
    static var firstReminder: Bool = false
    static var iPhoneX: Bool = false

}
