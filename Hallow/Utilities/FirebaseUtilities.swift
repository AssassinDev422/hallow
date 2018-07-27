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
import Firebase
import UIKit
import RealmSwift

class FirebaseUtilities {
    
    // MARK: - Load prayers

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
    
    // MARK: - User data management
    
    static func createUserData(withEmail email: String, withName name: String) {
        let db = Firestore.firestore()
        let dateStored = Date(timeIntervalSinceNow: 0)
        let guide = ""
        let isFirstDay = true
        let timeInPrayer = 0.00
        let streak: Int = 0
        let _completedPrayers = ""
        let mostRecentPrayerDate = Date(timeIntervalSince1970: 0)
        let nextPrayerTitle = "Day 1"
        db.collection("user_v2").document(email).setData([
            "Name": name,
            "Email": email,
            "Date Stored": dateStored,
            "Guide": guide,
            "First Day": isFirstDay,
            "Time in Prayer": timeInPrayer,
            "Streak": streak,
            "Completed Prayers": _completedPrayers,
            "Most Recent Prayer Date": mostRecentPrayerDate,
            "Next Prayer Title": nextPrayerTitle,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
        }
    }
    
    static func loadUserData(byUserEmail email: String,
                             _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection("user_v2").document(email).getDocument { result, error in
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
    
    static func syncUserData(completionBlock: @escaping () -> Void) {
        let realm = try! Realm() //TODO: Change to do catch - not sure if I need this
        guard let user = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        let db = Firestore.firestore()
        let dateStored = Date(timeIntervalSinceNow: 0)
        
        db.collection("user_v2").document(user.email).updateData([
            "Name": user.name,
            "Email": user.email,
            "Date Stored": dateStored,
            "Guide": user.guide,
            "First Day": user.isFirstDay,
            "Time in Prayer": user.timeInPrayer,
            "Streak": user.streak,
            "Completed Prayers": user._completedPrayers,
            "Most Recent Prayer Date": user.mostRecentPrayerDate,
            "Next Prayer Title": user.nextPrayerTitle,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)") //TODO: Make useful error
                } else {
                    print("Document added")
                    completionBlock()
                }
        }
    }
    
    static func logOut(viewController: BaseViewController, completionBlock: () -> Void) {
        do {
            try Auth.auth().signOut()
            print("IN DO")
            completionBlock()
        } catch let error {
            print(error.localizedDescription)
            BaseViewController().errorAlert(message: "\(error.localizedDescription)", viewController: viewController) //TODO: Check if this works
        }
    }
        
    // MARK: - Journal entries
    
    static func loadJournalEntries(byUserEmail email: String,
                                         _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        
        db.collection("user_v2").document(email).collection("journal").getDocuments { result, error in
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
    
    static func saveReflection(ofType type: String, byUserEmail email: String, withEntry entry: String, withTitle title: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: NSDate() as Date)
        let dateStored = Date(timeIntervalSinceNow: 0.00)
        var ref: DocumentReference? = nil
        
        ref = db.collection("user_v2").document(email).collection(type).addDocument(data: [
            "Date": date,
            "Date Stored": dateStored,
            "Entry": entry,
            "Prayer Title": title
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
        } else {
                print("Document added with ID: \(email)")
                let journalEntry = JournalEntry()
                journalEntry.date = date
                journalEntry.dateStored = dateStored
                journalEntry.docID = ref!.documentID
                journalEntry.entry = entry
                journalEntry.prayerTitle = title
                RealmUtilities.saveJournalEntry(withEntry: journalEntry)
            }
        }
        
    }
    
    static func updateReflection(withDocID docID: String, byUserEmail email: String, withEntry entry: String, withTitle title: String) {
        let db = Firestore.firestore()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: NSDate() as Date)
        let dateStored = Date(timeIntervalSinceNow: 0.00)

        db.collection("user_v2").document(email).collection("journal").document(docID).updateData([
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
        
        // FIXME: Need some realm function here
    }
    
    static func sendFeedback(ofType type: String, byUserEmail email: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user_v2").document(email).collection(type).addDocument(data: [
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
    
    static func loadProfilePicture(byUserEmail userEmail: String, completionBlock: @escaping (UIImage) -> Void) {
        let path = "profilePictures/\(userEmail).png"
        
        let destinationFileURL = BaseViewController().urlInDocumentsDirectory(forPath: path) //TODO: Check if this works
        
        print("attempting to download: \(path)...")
        
        let pathReference = Storage.storage().reference(withPath: path)
        
        pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("Error downloading image: \(error) -> setting to standard image")
                completionBlock(#imageLiteral(resourceName: "profileWithCircle"))
            } else {
                print("Downloaded image: \(path)")
                let fileURL = BaseViewController().urlInDocumentsDirectory(forPath: path) //TODO: Check if this works
                completionBlock(UIImage(contentsOfFile: fileURL.path)!)
            }
        }
    }
    
    // MARK: - Delete file
    
    static func deleteFile(ofType type: String, byUserEmail userEmail: String, withID document: String) {
        let db = Firestore.firestore()
        db.collection("user_v2").document(userEmail).collection(type).document(document).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
        
}
