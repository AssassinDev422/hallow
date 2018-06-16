//
//  FirebaseUtilities.swift
//  Hallow
//
//  Created by Alex Jones and Josh Wright on 5/5/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseUtilities {
    
    // MARK: - Load docs
    
    static func loadAllDocuments(ofType type: String, orderedBy order: String,
                                        _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection(type).order(by: order).getDocuments { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading prayers from Firestore: \(error)")
                } else {
                    print("While fetching prayers, the results were nil, but there was no error. That's weird.")
                }
                callback([])
                return
            }
            
            callback(result.documents)
        }
    }
    
    static func loadAllDocumentsFromUser(ofType type: String, byUser userID: String,
                                        _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection("user").document(userID).collection(type).getDocuments { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading files from Firestore: \(error)")
                } else {
                    print("While fetching files, the results were nil, but there was no error. That's weird.")
                }
                callback([])
                return
            }
            callback(result.documents)
        }
    }
    
    static func loadUserData(byUser userID: String,
                                         _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection("user").document(userID).getDocument { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading files from Firestore: \(error)")
                } else {
                    print("While fetching files, the results were nil, but there was no error. That's weird.")
                }
                callback([])
                return
            }
            callback([result]) // ???
        }
    }

    static func loadAllDocumentsByGuideStandardLength(ofType type: String, byGuide guide: String,
                                 _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection(type).whereField("guide", isEqualTo: guide).whereField("length", isEqualTo: "10 mins").getDocuments { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading prayers from Firestore: \(error)")
                } else {
                    print("While fetching prayers, the results were nil, but there was no error. That's weird.")
                }
                callback([])
                return
            }
            callback(result.documents)
        }
    }
    
    
    
    
    static func loadSpecificDocumentByGuideAndLength(ofType type: String, withTitle title: String, byGuide guide: String, withLength length: String,
                                 _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection(type).whereField("title", isEqualTo: title).whereField("guide", isEqualTo: guide).whereField("length", isEqualTo: length).getDocuments { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading prayers from Firestore: \(error)")
                } else {
                    print("While fetching prayers, the results were nil, but there was no error. That's weird.")
                }
                callback([]) //TODO: Probably want to change to single file load
                return
            }
            callback(result.documents)
        }
    }
    
    // MARK: - Save data
    
    static func saveUser(ofType type: String, withID ID: String, withName name: String, withEmail email: String, withPassword password: String) {
        let db = Firestore.firestore()
        db.collection(type).document(ID).setData([
            "Name": name,
            "Email": email,
            "Password": password,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
        }
    }
    
    static func saveReflection(ofType type: String, byUserID userID: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d, yyyy"
        let date = formatter.string(from: NSDate() as Date)
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(userID).collection(type).addDocument(data: [
            "Date": date,
            "Date Stored": dateStored,
            "Entry": entry
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
        } else {
                print("Document added with ID: \(userID)")
            }
        }
    }
    
    static func sendFeedback(ofType type: String, byUserID userID: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(userID).collection(type).addDocument(data: [
            "Date Stored": dateStored,
            "Entry": entry
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(userID)")
            }
        }
    }
        
    static func saveAndResetUserConstants(ofType type: String, byUserID userID: String, guide: String, isFirstDay: Bool, hasCompleted: Bool, hasSeenCompletionScreen: Bool, hasStartedListening: Bool, hasLoggedOutOnce: Bool) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(userID).collection(type).addDocument(data: [
            "Date Stored": dateStored,
            "guide": guide,
            "isFirstDay": isFirstDay,
            "hasCompleted": hasCompleted,
            "hasSeenCompletionScreen": hasSeenCompletionScreen,
            "hasStartedListening": hasStartedListening,
            "hasLoggedOutOnce": hasLoggedOutOnce,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(userID)")
                Constants.firebaseDocID = ""
                Constants.guide = "Francis"
                Constants.isFirstDay = true
                Constants.hasCompleted = false
                Constants.hasSeenCompletionScreen = false
                Constants.hasStartedListening = false
                Constants.hasLoggedOutOnce = false
            }
        }
    }
    
    static func preOrderResponse(ofType type: String, byUserID userID: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(userID).collection(type).addDocument(data: [
            "Date Stored": dateStored,
            "Entry": entry
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(userID)")
            }
        }
    }
    
    static func saveStats(byUserID userID: String, withTimeInPrayer timeInPrayer: Double) {
        let db = Firestore.firestore()
        db.collection("user").document(userID).collection("stats").addDocument(data: [
            "Time in Prayer": timeInPrayer,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added by user: \(userID)")
                }
        }
    }
    
    // MARK: - Track progress
    
    static func saveCompletedPrayer(byUserID userID: String, withPrayerTitle prayerTitle: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        db.collection("user").document(userID).collection("completedPrayers").addDocument(data: [
            "Date Stored": dateStored,
            "Prayer Title": prayerTitle,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added by user: \(userID)")
            }
        }
    }
    
    static func saveStartedPrayer(byUserID userID: String, withPrayerTitle prayerTitle: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        db.collection("user").document(userID).collection("startedPrayers").addDocument(data: [
            "Date Stored": dateStored,
            "Prayer Title": prayerTitle,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added by user: \(userID)")
                }
        }
    }
    
    // MARK: - Delete file
    
    static func deleteFile(ofType type: String, byUser userID: String, withID document: String) {
        let db = Firestore.firestore()
        db.collection("user").document(userID).collection(type).document(document).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
        
}
