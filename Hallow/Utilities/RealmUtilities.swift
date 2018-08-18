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
    
    // MARK: - User data
    
    static func createUserData(withEmail email: String, withName name: String, completionBlock: () -> Void) {
        let user = User()
        user.email = email
        user.name = name
        user.dateStored = Date(timeIntervalSinceNow: 0)
        user.guide = User.Guide.francis
        user.isFirstDay = true
        user.isLoggedIn = true
        user.timeInPrayer = 0.00
        user.streak = 0
        user.completedPrayers = [""]
        user.mostRecentPrayerDate = Date(timeIntervalSince1970: 0)
        user.nextPrayerIndex = 1
        
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user)
                completionBlock()
            }
        } catch let error {
            print("REALM: Error in utilities - createUserData: \(error.localizedDescription)")
        }
    }
    
    static func signInUser(withUser user: User, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(user, update: true)
                user.isLoggedIn = true
                print("IN USER SIGN IN - NEXT PRAYER: \(user.nextPrayerIndex)")
                completionBlock()
            }
        } catch {
            print("REALM: Error in utilities - signInUser")
        }
    }
    
    static func deleteUser() {
        do {
            let realm = try Realm()
            let user = realm.objects(User.self)
            try realm.write {
                realm.delete(user)
            }
        } catch {
            print("REALM: Error in utilities - deleteUser")
        }
    }
    
    // MARK: - Journal entries
    
    static func saveJournalEntry(entryText: String, prayerTitle: String, completionBlock: (() -> Void)? = nil) {
        guard let user = User.current else {
            print("Error in save journal entry")
            return
        }
        let journalEntry = JournalEntry()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: NSDate() as Date)
        let dateStored = Date(timeIntervalSinceNow: 0.00)
        journalEntry.date = date
        journalEntry.dateStored = dateStored
        journalEntry.docID = RealmUtilities.calcDocID() + 1
        journalEntry.entry = entryText
        journalEntry.prayerTitle = prayerTitle
        journalEntry.userEmail = user.email
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(journalEntry)
                completionBlock?()
            }
        } catch {
            print("REALM: Error in utilities - saveJournalEntry")
        }
    }
    
    static func calcDocID() -> Int {
        do {
            let realm = try Realm()
            let journal = realm.objects(JournalEntry.self)
            return journal.count
        } catch {
            print("REALM: Error in utilities - loadJournalEntries")
            return 0
        }
    }
    
    static func deleteJournalEntry(fromUser user: User, withID docID: Int, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            let journalEntry = realm.objects(JournalEntry.self).filter("userEmail = %a AND docID = %a", user.email, docID)
            try realm.write {
                realm.delete(journalEntry)
                completionBlock()
            }
        } catch {
            print("REALM: Error in utilities - deleteJournalEntry")
        }
    }
    
    static func updateJournalEntry(fromUser user: User, withID docID: Int, withEntry entry: String, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            if let journalEntry = realm.objects(JournalEntry.self).filter("userEmail = %a AND docID = %a", user.email, docID).first {
                try realm.write {
                    journalEntry.entry = entry
                    completionBlock()
                }
            }
        } catch {
            print("REALM: Error in utilities - updateJournalEntry")
        }
    }
    
    // MARK: Prayer and audio
    
    static func addPrayers(withPrayers prayers: [Prayer]) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(prayers, update: true)
            }
        } catch {
            print("REALM: Error in utilities - addPrayers")
        }
    }
    
    static func addChapters(withChapters chapters: [Chapter]) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(chapters, update: true)
            }
        } catch {
            print("REALM: Error in utilities - addChapters")
        }
    }
    
    static func prayerCompleted(completedPrayerIndex prayerIndex: Int, withStartTime startTime: Date) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("REALM: Error in utilies - prayerCompleted")
                return
            }
            try realm.write {
                user.completedPrayers.append("\(prayerIndex)")
                var completedPrayers = user.completedPrayers
                completedPrayers.sort()
                guard let _nextPrayerIndex = Int(String(completedPrayers[completedPrayers.count-1])) else {
                    print("REALM: Error in prayerCompleted Int()")
                    return
                }
                user.nextPrayerIndex = _nextPrayerIndex + 1
                
                let calendar = Calendar.current
                let isNextDay = calendar.isDateInYesterday(user.mostRecentPrayerDate)
                let isToday = calendar.isDateInToday(user.mostRecentPrayerDate)
                if isNextDay {
                    user.streak += 1
                } else {
                    if !isToday {
                        user.streak = 1
                    }
                }
                
                let addedTimeTracker = Date().timeIntervalSince(startTime)
                user.timeInPrayer += addedTimeTracker
            }
        } catch {
            print("REALM: Error in utilities - prayerCompleted")
        }
    }
    
    static func prayerExited(withStartTime startTime: Date) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("Error in realm prayer exited")
                return
            }
            try realm.write {
                let addedTimeTracker = Date().timeIntervalSince(startTime)
                user.timeInPrayer += addedTimeTracker
            }
        } catch {
            print("REALM: Error in utilities - prayerExited")
        }
    }
    
    // MARK: Constants
    
    static func updateIsFirstDay(withIsFirstDay isFirstDay: Bool) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("Error in realm isFirstDay update")
                return
            }
            try realm.write {
                user.isFirstDay = isFirstDay
            }
        } catch {
            print("REALM: Error in utilities - updateIsFirstDay")
        }
    }
    
    static func updateGuide(withGuide guide: User.Guide, completionBlock: (() -> Void)? = nil) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("Error in realm guide update")
                return
            }
            try realm.write {
                user.guide = guide
                completionBlock?()
            }
        } catch {
            print("REALM: Error in utilities - updateGuide")
        }
    }
    
    static func changeIsLoggedIn(isLoggedIn: Bool, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("Error in realm guide update")
                return
            }
            try realm.write {
                user.isLoggedIn = isLoggedIn
                completionBlock()
            }
        } catch {
            print("REALM: Error in utilities - isLoggedIn")
        }
    }
}
