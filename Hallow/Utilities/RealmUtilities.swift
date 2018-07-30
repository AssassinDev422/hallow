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
        user.guide = User.Guide.Francis
        user.isFirstDay = true
        user.timeInPrayer = 0.00
        user.streak = 0
        user.completedPrayers = [""]
        user.mostRecentPrayerDate = Date(timeIntervalSince1970: 0)
        
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
                realm.add(user)
                print("IN USER SIGN IN - NEXT PRAYER: \(user.nextPrayerTitle)")
                completionBlock()
            }
        } catch {
            print("REALM: Error in utilities - signInUser")
        }
        loadJournalEntries(withUser: user)
    }
    
    static func saveJournalEntry(withEntry entry: JournalEntry) {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(entry)
            }
        } catch {
            print("REALM: Error in utilities - saveJournalEntry")
        }
    }
    
    static func loadJournalEntries(withUser user: User) {
        var journalEntries: [JournalEntry] = []
        FirebaseUtilities.loadJournalEntries(byUserEmail: user.email) { results in
            journalEntries = results.map(JournalEntry.init)
            journalEntries.sort{$0.dateStored > $1.dateStored}
            do {
                let realm = try Realm()
                let oldJournal = realm.objects(JournalEntry.self)
                try realm.write {
                    realm.delete(oldJournal)
                }
                for journalEntry in journalEntries {
                    try realm.write {
                        realm.add(journalEntry)
                    }
                }
            } catch {
                print("REALM: Error in utilities - loadJournalEntries")
            }
        }
    }
    
    static func deleteJournalEntry(withID docID: String, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            let journalEntry = realm.objects(JournalEntry.self).filter("docID = %a", docID)
            try realm.write {
                realm.delete(journalEntry)
                completionBlock()
            }
        } catch {
            print("REALM: Error in utilities - deleteJournalEntry")
        }
    }
    
    static func updateJournalEntry(withID docID: String, withEntry entry: String, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            if let journalEntry = realm.objects(JournalEntry.self).filter("docID = %a", docID).first {
                try realm.write {
                    journalEntry.entry = entry
                    completionBlock()
                }
            }
        } catch {
            print("REALM: Error in utilities - updateJournalEntry")
        }
    }
    
    static func prayerCompleted(completedPrayerTitle prayerTitle: String, withStartTime startTime: Date) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("REALM: Error in utilies - prayerCompleted")
                return
            }
            try realm.write {
                user.completedPrayers.append(prayerTitle)
                var completedPrayers = user.completedPrayers // TODO: Might have to do all the weird realm stuff
                completedPrayers.sort() // TODO: Might have to change to realm sort
                var nextPrayerTitle = completedPrayers[completedPrayers.count-1]
                guard let last = nextPrayerTitle.last else {
                    print("REALM: Error in prayerCompleted")
                    return
                }
                guard let _dayNumber = Int(String(last)) else {
                    print("REALM: Error in prayerCompleted Int()")
                    return
                }
                let dayNumber: Int = _dayNumber + 1
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
    
    static func setCurrentAudioTime(withCurrentTime currentTime: Double) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("Error in realm prayer exited")
                return
            }
            try realm.write {
                user.pausedTime = currentTime //TODO: Does it keep track of time when you exit out and go back in?
            }
        } catch {
            print("REALM: Error in utilities - setCurrentAudioTime")
        }
    }
    
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
    
    static func updateGuide(withGuide guide: User.Guide, completionBlock: () -> Void) {
        do {
            let realm = try Realm()
            guard let user = realm.objects(User.self).first else {
                print("Error in realm guide update")
                return
            }
            try realm.write {
                user.guide = guide //TODO: Not sure whether this updates _guide or not
                completionBlock()
            }
        } catch {
            print("REALM: Error in utilities - updateGuide")
        }
    }
    
    static func deleteUser() {
        do {
            let realm = try Realm() 
            let user = realm.objects(User.self)
            let journal = realm.objects(JournalEntry.self)
            try realm.write {
                realm.delete(user)
                realm.delete(journal)
            }
        } catch {
            print("REALM: Error in utilities - deleteUser")
        }
    }
    
    static func addPrayers(withPrayers prayers: [PrayerItem]) {
        do {
            let realm = try Realm()
            let oldPrayers = realm.objects(PrayerItem.self)
            try realm.write {
                realm.delete(oldPrayers)
                realm.add(prayers)
            }
        } catch {
            print("REALM: Error in utilities - addPrayers")
        }
    }
}
