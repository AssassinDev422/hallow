//
//  FirebaseUtilities.swift
//  Hallow
//
//  Created by Alex Jones and Josh Wright on 5/5/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

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
    
    static func loadAllDocumentsFromUser(ofType type: String, byUserEmail email: String,
                                        _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection("user").document(email).collection(type).getDocuments { result, error in
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
    
    static func loadUserData(byUserEmail email: String,
                                         _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection("user").document(email).getDocument { result, error in
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

    static func loadAllPrayersWithLength(ofType type: String, withLength length: String,
                                 _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection(type).whereField("length", isEqualTo: length).getDocuments { result, error in
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
        db.collection(type).document(email).setData([
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
    
    static func saveReflection(ofType type: String, byUserEmail email: String, withEntry entry: String, withTitle title: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: NSDate() as Date)
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(email).collection(type).addDocument(data: [
            "Date": date,
            "Date Stored": dateStored,
            "Entry": entry,
            "Prayer Title": title
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
        } else {
                print("Document added with ID: \(email)")
            }
        }
    }
    
    static func updateReflection(withDocID docID: String, byUserEmail email: String, withEntry entry: String, withTitle title: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: NSDate() as Date)
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(email).collection("journal").document(docID).updateData([
            "Date": date,
            "Date Stored": dateStored,
            "Entry": entry,
            "Prayer Title": title
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(email)")
            }
        }
    }
    
    static func sendFeedback(ofType type: String, byUserEmail email: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(email).collection(type).addDocument(data: [
            "Date Stored": dateStored,
            "Entry": entry
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(email)")
            }
        }
    }
    
    static func preOrderResponse(ofType type: String, byUserEmail email: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(email).collection(type).addDocument(data: [
            "Date Stored": dateStored,
            "Entry": entry
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(email)")
            }
        }
    }
    
    static func saveStats(byUserEmail email: String, withTimeInPrayer timeInPrayer: Double, withStreak streak: Int) {
        let db = Firestore.firestore()
        db.collection("user").document(email).collection("stats").addDocument(data: [
            "Time in Prayer": timeInPrayer,
            "Streak": streak
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added by user: \(email)")
                }
        }
    }
    
    static func updateStats(withDocID docID: String, byUserEmail email: String, withTimeInPrayer timeInPrayer: Double, withStreak streak: Int) {
        let db = Firestore.firestore()
        db.collection("user").document(email).collection("stats").document(docID).updateData([
            "Time in Prayer": timeInPrayer,
            "Streak": streak
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added by user: \(email)")
            }
        }
    }
    
    // MARK: - Track progress
    
    static func saveCompletedPrayer(byUserEmail email: String, withPrayerTitle prayerTitle: String) {
        let db = Firestore.firestore()
        //WIP
        let dateStored = Date(timeIntervalSinceNow: 0)
        db.collection("user").document(email).collection("completedPrayers").addDocument(data: [
            "Date Stored": dateStored,
            "Prayer Title": prayerTitle,
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added by user: \(email)")
            }
        }
    }
    
    static func saveStartedPrayer(byUserEmail email: String, withPrayerTitle prayerTitle: String) {
        let db = Firestore.firestore()
        let dateStored = Date(timeIntervalSinceNow: 0)
        db.collection("user").document(email).collection("startedPrayers").addDocument(data: [
            "Date Stored": dateStored,
            "Prayer Title": prayerTitle,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added by user: \(email)")
                }
        }
    }
    
    // MARK: - Periodic save of data
    
    static func updateConstantsFile(withDocID docID: String, byUserEmail userEmail: String, guide: String, isFirstDay: Bool, hasCompleted: Bool, hasSeenCompletionScreen: Bool, hasStartedListening: Bool, hasLoggedOutOnce: Bool) {
        print("Updating document now")
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(userEmail).collection("constants").document(docID).updateData([
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
                    print("Document updated for the user: \(userEmail)")
                }
        }
    }
    
    // MARK: - Upload an image
    
    static func uploadProfilePicture(withImage image: UIImage, byUserEmail userEmail: String) {
        let storageRef = Storage.storage().reference()
        let refString = "profilePictures/\(userEmail).png"
        let imageRef = storageRef.child(refString)
        let data = UIImageJPEGRepresentation(image, 0.5)
        
        imageRef.delete { error in
            if error != nil {
                print("Error in deleting image")
                imageRef.putData(data!, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        print("Error occured in uploading the image")
                        return
                    }
                    print("Successfully uploaded image")
                }
            } else {
                print("No error in deleting image")
                imageRef.putData(data!, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        print("Error occured in uploading the image")
                        return
                    }
                    print("Successfully uploaded image")
                }
            }
        }
    }
    
    static func loadProfilePicture(byUserEmail userEmail: String) {
        let path = "profilePictures/\(userEmail).png"
        
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: path)
        
        print("attempting to download: \(path)...")
        
        let pathReference = Storage.storage().reference(withPath: path)
        
        pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("Error downloading image: \(error)")
            } else {
                print("Downloaded image: \(path)")
                let fileURL = Utilities.urlInDocumentsDirectory(forPath: path)
                LocalFirebaseData.profilePicture = UIImage(contentsOfFile: fileURL.path)!
            }
        }
    }
        
}
