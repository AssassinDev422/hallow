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
    
    static let userLocation = "User"
    static let prayerLocation = "Prayers"
    static let chapterLocation = "Chapters"
    
    // MARK: - Load prayers

    static func loadPrayers(completionBlock: @escaping ([Prayer]) -> Void) {
        let db = Firestore.firestore()
        db.collection(prayerLocation).getDocuments { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading prayers from Firestore: \(error)")
                } else {
                    print("While fetching prayers, the results were nil, but there was no error. That's weird.")
                }
                return
            }
            let results = result.documents
            var prayers = results.map(Prayer.init)
            prayers.sort{$0.title < $1.title}
            completionBlock(prayers)
        }
    }
    
    static func loadChapters(completionBlock: @escaping ([Chapter]) -> Void) {
        let db = Firestore.firestore()
        db.collection(chapterLocation).getDocuments { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    print("Got an error loading prayers from Firestore: \(error)")
                } else {
                    print("While fetching prayers, the results were nil, but there was no error. That's weird.")
                }
                return
            }
            let results = result.documents
            var chapters = results.map(Chapter.init)
            chapters.sort{$0.index < $1.index}
            chapters.sort{$0.categoryIndex < $1.categoryIndex}
            completionBlock(chapters)
        }
    }
    
    // MARK: - User data management
    
    static func createUserData(withEmail email: String, withName name: String) {
        let db = Firestore.firestore()
        let dateStored = Date(timeIntervalSinceNow: 0)
        let guide = "Not yet set"
        let isFirstDay = true
        let isLoggedIn = true
        let timeInPrayer = 0.00
        let streak: Int = 0
        let _completedPrayers = ""
        let mostRecentPrayerDate = Date(timeIntervalSince1970: 0)
        let nextPrayerIndex = 1
        db.collection(userLocation).document(email).setData([
            "Name": name,
            "Email": email,
            "Date Stored": dateStored,
            "Guide": guide,
            "First Day": isFirstDay,
            "Logged In": isLoggedIn,
            "Time in Prayer": timeInPrayer,
            "Streak": streak,
            "Completed Prayers": _completedPrayers,
            "Most Recent Prayer Date": mostRecentPrayerDate,
            "Next Prayer Index": nextPrayerIndex,
            ]) { err in
                if let err = err {
                    fatalError("Error adding document: \(err)")
                } else {
                    print("Document added")
                }
        }
    }
    
    static func loadUserData(byUserEmail email: String,
                             _ callback: @escaping ([DocumentSnapshot]) -> ()) {
        let db = Firestore.firestore()
        db.collection(userLocation).document(email).getDocument { result, error in
            guard let result = result, error == nil else {
                if let error = error {
                    fatalError("FIREBASE: Got an error loading files from Firestore: \(error)")
                } else {
                    print("While fetching files, the results were nil, but there was no error. That's weird.")
                }
                callback([])
                return
            }
            callback([result])
        }
    }
    
    static func syncUserData(completionBlock: (() -> Void)? = nil) {
        do {
            let realm = try Realm() 
            guard let user = realm.objects(User.self).first else {
                print("FIREBASE: Error in utilies - syncUserData")
                return
            }
            let db = Firestore.firestore()
            let dateStored = Date(timeIntervalSinceNow: 0)
            
            db.collection(userLocation).document(user.email).updateData([
                "Name": user.name,
                "Email": user.email,
                "Date Stored": dateStored,
                "Guide": user._guide,
                "First Day": user.isFirstDay,
                "Logged In": user.isLoggedIn,
                "Time in Prayer": user.timeInPrayer,
                "Streak": user.streak,
                "Completed Prayers": user._completedPrayers,
                "Most Recent Prayer Date": user.mostRecentPrayerDate,
                "Next Prayer Index": user.nextPrayerIndex
                ]) { err in
                    if let err = err {
                        print("Error adding document: \(err)") //TODO: Make useful error
                    } else {
                        print("Document added")
                        completionBlock?()
                    }
            }
        } catch {
            print("REALM: Error in Firebase Utilities - syncUserData")
        }
    }
    
    static func setLoggedInFalse(user: User, completionBlock: (() -> Void)? = nil) {
        let db = Firestore.firestore()
        db.collection(userLocation).document(user.email).updateData([
            "Logged In": false,
            ]) { err in
                if let err = err {
                    print("Error changing logged in status: \(err)") //TODO: Make useful error
                } else {
                    print("Logged In status changed")
                    RealmUtilities.changeIsLoggedIn(isLoggedIn: false) {
                        completionBlock?()
                    }
                }
        }
    }
    
    static func logOut(viewController: BaseViewController, completionBlock: () -> Void) {
        do {
            try Auth.auth().signOut()
            completionBlock()
        } catch let error {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    static func saveOtherData(ofType type: String, byUserEmail email: String, withEntry entry: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection(type).addDocument(data: [
            "User": email,
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
            guard let data = data else {
                print("FIREBASE: Error in uploadProfilePicture")
                return
            }
            if error != nil {
                print("Error in deleting image")
                imageRef.putData(data, metadata: nil) { (metadata, error) in
                    guard metadata != nil else {
                        print("Error occured in uploading the image")
                        return
                    }
                    print("Successfully uploaded image")
                }
            } else {
                print("No error in deleting image")
                imageRef.putData(data, metadata: nil) { (metadata, error) in
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
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: path) //TODO: Check if this works
        print("attempting to download: \(path)...")
        let pathReference = Storage.storage().reference(withPath: path)
        
        pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("Error downloading image: \(error) -> setting to standard image")
                completionBlock(#imageLiteral(resourceName: "profileWithCircle"))
            } else {
                print("Downloaded image: \(path)")
                let fileURL = Utilities.urlInDocumentsDirectory(forPath: path)
                guard let image = UIImage(contentsOfFile: fileURL.path) else {
                    print("FIREBASE: Error in loadProfilePicture")
                    return
                }
                completionBlock(image)
            }
        }
    }
    
    // MARK: - Delete file
    
    static func deleteFile(ofType type: String, byUserEmail userEmail: String, withID document: String) {
        let db = Firestore.firestore()
        db.collection(userLocation).document(userEmail).collection(type).document(document).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}
