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
    
    enum Guide {
        case Francis
        case Abby
    }
    
    static var isFirstDay: Bool = false
    static var hasCompleted: Bool = false
    static var hasSeenCompletionScreen: Bool = false
    static var hasStartedListening: Bool = false
    static var hasLoggedOutOnce: Bool = false
        
    // Don't change with log in log out but not stored after device closes and re-opens
    static var pausedTime: Double = 0.00

}
