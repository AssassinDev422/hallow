//
//  RealmUtilities.swift
//  Hallow
//
//  Created by Alex Jones on 7/25/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import RealmSwift

class RealmUtilities {
    
    static func createUserData(withEmail email: String, withName name: String, completionBlock: () -> Void) {
        let user = User()
        user.email = email
        user.name = name
        user.dateStored = Date(timeIntervalSinceNow: 0)
        user.guide = ""
        user.isFirstDay = true
        user.timeInPrayer = 0.00
        user.streak = 0
        user.completedPrayers = [""]
        user.mostRecentPrayerDate = Date(timeIntervalSince1970: 0)
        
        let realm = try! Realm() //TODO: Fix !
        try! realm.write { //TODO: change to do, catch try
            realm.add(user)
            completionBlock()
        }
    }
    
    static func signInUser(withUser user: User, completionBlock: () -> Void) {
        let realm = try! Realm() //TODO: Fix !
        try! realm.write { //TODO: change to do, catch try
            realm.add(user)
            print("IN USER SIGN IN - NEXT PRAYER: \(user.nextPrayerTitle)")
            completionBlock()
        }
        loadJournalEntries(withUser: user)
    }
    
    static func saveJournalEntry(withEntry entry: JournalEntry) {
        let realm = try! Realm() //TODO: Fix !
        try! realm.write { //TODO: change to do, catch try
            realm.add(entry)
        }
    }
    
    static func loadJournalEntries(withUser user: User) {
        var journalEntries: [JournalEntry] = []
        FirebaseUtilities.loadJournalEntries(byUserEmail: user.email) { results in
            journalEntries = results.map(JournalEntry.init)
            journalEntries.sort{$0.dateStored > $1.dateStored}
            
            let realm = try! Realm() //TODO: Change to do catch
            let oldJournal = realm.objects(JournalEntry.self)
            try! realm.write { //TODO: Change to do catch
                realm.delete(oldJournal)
            }
            
            for journalEntry in journalEntries {
                try! realm.write { //TODO: change to do, catch try
                    realm.add(journalEntry)
                }
            }
        }
    }
    
    static func deleteJournalEntry(withID docID: String, completionBlock: () -> Void) {
        let realm = try! Realm()
        let journalEntry = realm.objects(JournalEntry.self).filter("docID = %a", docID)
        try! realm.write {
            realm.delete(journalEntry)
            completionBlock()
        }
    }
    
    static func updateJournalEntry(withID docID: String, withEntry entry: String, completionBlock: () -> Void) {
        let realm = try! Realm()
        if let journalEntry = realm.objects(JournalEntry.self).filter("docID = %a", docID).first {
            try! realm.write {
                journalEntry.entry = entry
                completionBlock()
            }
        }
    }
    
    static func prayerCompleted(completedPrayerTitle prayerTitle: String, withStartTime startTime: Date) {
        let realm = try! Realm() //TODO: Change to do catch
        guard let user = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        
        try! realm.write {
            user.completedPrayers.append(prayerTitle)
            var completedPrayers = user.completedPrayers // TODO: Might have to do all the weird realm stuff
            completedPrayers.sort() // TODO: Might have to change to realm sort
            var nextPrayerTitle = completedPrayers[completedPrayers.count-1]
            var dayNumber: Int = Int(String(nextPrayerTitle.last!))!
            dayNumber += 1
            let newDayNumber: String = String(dayNumber)
            nextPrayerTitle.removeLast()
            nextPrayerTitle.append(newDayNumber)
            if dayNumber == 10 {
                user.nextPrayerTitle = "Day 9"
            } else {
                user.nextPrayerTitle = nextPrayerTitle
            }
            
            let calendar = Calendar.current
            let isNextDay = calendar.isDateInYesterday(user.mostRecentPrayerDate)
            let isToday = calendar.isDateInToday(user.mostRecentPrayerDate)
            if isNextDay == true {
                user.streak += 1
            } else {
                if isToday == false {
                    user.streak = 1
                }
            }
            
            let addedTimeTracker = Date().timeIntervalSince(startTime)
            user.timeInPrayer += addedTimeTracker
        }
        
    }
    
    static func prayerExited(withStartTime startTime: Date) {
        let realm = try! Realm() //TODO: Change to do catch
        guard let user = realm.objects(User.self).first else {
            print("Error in realm prayer exited")
            return
        }
        
        try! realm.write {
            let addedTimeTracker = Date().timeIntervalSince(startTime)
            user.timeInPrayer += addedTimeTracker
        }
    }
    
    static func setCurrentAudioTime(withCurrentTime currentTime: Double) {
        let realm = try! Realm() //TODO: Change to do catch
        guard let user = realm.objects(User.self).first else {
            print("Error in realm prayer exited")
            return
        }
        
        try! realm.write {
            user.pausedTime = currentTime //TODO: Does it keep track of time when you exit out and go back in?
        }
    }
    
    static func updateIsFirstDay(withIsFirstDay isFirstDay: Bool) {
        let realm = try! Realm() //TODO: Change to do catch
        guard let user = realm.objects(User.self).first else {
            print("Error in realm isFirstDay update")
            return
        }
        try! realm.write {
            user.isFirstDay = isFirstDay
        }
    }
    
    static func updateGuide(withGuide guide: String, completionBlock: () -> Void) {
        let realm = try! Realm() //TODO: Change to do catch
        guard let user = realm.objects(User.self).first else {
            print("Error in realm guide update")
            return
        }
        try! realm.write {
            user.guide = guide
            completionBlock()
        }
    }
    
    static func deleteUser() {
        let realm = try! Realm() //TODO: Change to do catch
        let user = realm.objects(User.self)
        let journal = realm.objects(JournalEntry.self)
        try! realm.write { //TODO: Change to do catch
            realm.delete(user)
            realm.delete(journal)
        }
    }
}
