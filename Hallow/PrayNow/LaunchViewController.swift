//
//  LaunchViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var signInOutlet: UIButton!
    @IBOutlet weak var prayerChallengeLabel: UILabel!
    
    var userData: User?
    var startedPrayers: [PrayerTracking] = []
    var completedPrayers: [PrayerTracking] = []
    var stats: StatsItem?
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
        
    var storedUserID: String?
    var storedUserEmail: String?
    
    var newFirebaseDocID: String?

    
    var userConstants: ConstantsItem?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideOutlets(shouldHide: true)
        
        if Constants.newBuild == true {
            firebaseLogOut()
            Constants.newBuild = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.userID = user?.uid
                self.userEmail = user?.email
                if Constants.newBuild == true {
                    self.logOut()
                    Constants.newBuild = false
                } else {
                    self.loadUserConstantsAndPrayers(fromUserEmail: self.userEmail!)
                }
            } else {
                self.load10minPrayers(skippingSignIn: false)
                print("no one is logged in")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Functions
    
    private func loadUserConstantsAndPrayers(fromUserEmail userEmail: String) {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "constants", byUserEmail: userEmail) { results in
            self.userConstants = results.map(ConstantsItem.init)[0]
            Constants.firebaseDocID = self.userConstants!.docID
            Constants.guide = self.userConstants!.guide
            Constants.isFirstDay = self.userConstants!.isFirstDay
            Constants.hasCompleted = self.userConstants!.hasCompleted
            Constants.hasSeenCompletionScreen = self.userConstants!.hasSeenCompletionScreen
            Constants.hasStartedListening = self.userConstants!.hasStartedListening
            Constants.hasLoggedOutOnce = self.userConstants!.hasLoggedOutOnce
            print("************Constants.isFirstDay in launch: \(Constants.isFirstDay)")
            print("LOADED USER CONSTANTS")
            print("Guide set at: \(Constants.guide)")
            print("Has started listening set at: \(Constants.hasStartedListening)")
            print("Guide pulled at: \(self.userConstants!.guide)")
            print("DocID: \(self.userConstants!.docID)")
            
            self.loadName()
        }
    }
    
    private func loadName() {
        FirebaseUtilities.loadUserData(byUserEmail: self.userEmail!) {results in
            self.userData = results.map(User.init)[0]
            print("USER DATA IN LAUNCH: \(String(describing: self.userData))")
            LocalFirebaseData.name = self.userData!.name
            
            self.loadStartedPrayers()
        }
    }
    
    private func loadStartedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUserEmail: self.userEmail!) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            print("STARTED PRAYERS IN LAUNCH: \(self.startedPrayers.count)")
            LocalFirebaseData.started = self.startedPrayers.count
            
            self.loadCompletedPrayers()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUserEmail: self.userEmail!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("COMPLETED PRAYERS IN LAUNCH: \(self.completedPrayers.count)")
            LocalFirebaseData.completed = self.completedPrayers.count

            self.loadTimeTracker()
        }
    }
    
    private func loadTimeTracker() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUserEmail: self.userEmail!) {results in
            self.stats = results.map(StatsItem.init)[0]
            LocalFirebaseData.timeTracker = self.stats!.timeInPrayer
            
            self.load10minPrayers(skippingSignIn: true)

        }
    }
    
    private func load10minPrayers(skippingSignIn: Bool) {
        LocalFirebaseData.prayers = []
        LocalFirebaseData.prayers10mins = []
        print("LOCAL FIREBASE DATA PRAYERS PRE-LOAD: \(LocalFirebaseData.prayers.count)")
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "10 mins") { results in
            LocalFirebaseData.prayers = results.map(PrayerItem.init)
            LocalFirebaseData.prayers.sort{$0.title < $1.title}
            LocalFirebaseData.prayers10mins = LocalFirebaseData.prayers
            print("LOCAL FIREBASE DATA PRAYERS POST LOAD: \(LocalFirebaseData.prayers.count)")
            
            self.load15minPrayers(skippingSignIn: skippingSignIn)
        }
    }
    
    private func load15minPrayers(skippingSignIn: Bool) {
        LocalFirebaseData.prayers15mins = []
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "15 mins") { results in
            LocalFirebaseData.prayers15mins = results.map(PrayerItem.init)
            LocalFirebaseData.prayers15mins.sort{$0.title < $1.title}
            
            self.load5minPrayers(skippingSignIn: skippingSignIn)
        }
    }
    
    private func load5minPrayers(skippingSignIn: Bool) {
        LocalFirebaseData.prayers5mins = []
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "5 mins") { results in
            LocalFirebaseData.prayers5mins = results.map(PrayerItem.init)
            LocalFirebaseData.prayers5mins.sort{$0.title < $1.title}
            
            if skippingSignIn == false {
                self.hideOutlets(shouldHide: false)
            } else {
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)
            }
        }
    }
    
    // Created so when the segue skips past this screen (when user is already logged in) it doesn't show the buttons
    
    private func hideOutlets(shouldHide: Bool) {
        self.signInOutlet.isHidden = shouldHide
        self.signUpOutlet.isHidden = shouldHide
        self.prayerChallengeLabel.isHidden = shouldHide
    }
    
    // Log out when deploying a new build
    
    private func logOut() {
        self.storedUserID = self.userID
        self.storedUserEmail = self.userEmail
        logOutData(ofType: "constants", byUserEmail: self.storedUserEmail!, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
    }
    
    private func logOutData(ofType type: String, byUserEmail userEmail: String, guide: String, isFirstDay: Bool, hasCompleted: Bool, hasSeenCompletionScreen: Bool, hasStartedListening: Bool, hasLoggedOutOnce: Bool) {
        print("IN LOG OUT DATA FUNCTION")
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        let ref = db.collection("user").document(userEmail).collection(type).addDocument(data: [
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
                    print("Document added with ID: \(userEmail)")
                    Constants.guide = "Francis"
                    Constants.isFirstDay = true
                    Constants.hasCompleted = false
                    Constants.hasSeenCompletionScreen = false
                    Constants.hasStartedListening = false
                    Constants.hasLoggedOutOnce = false
                    
                    self.deleteFile(ofType: "constants", byUserEmail: userEmail, withID: Constants.firebaseDocID)
                }
        }
        newFirebaseDocID = ref.documentID
    }
    
    private func deleteFile(ofType type: String, byUserEmail userEmail: String, withID document: String) {
        print("IN DELETE FILE FUNCTION")
        let db = Firestore.firestore()
        db.collection("user").document(userEmail).collection(type).document(document).delete() { error in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed with ID: \(document)")
                
                Constants.firebaseDocID = self.newFirebaseDocID!
                Constants.hasLoggedOutOnce = true
                self.firebaseLogOut()
            }
        }
    }
    
    private func firebaseLogOut() {
        do {
            try Auth.auth().signOut()
            print("FIREBASE LOG OUT FUNCTION")
            self.resetLocalFirebaseData()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func resetLocalFirebaseData() {
        print("IN RESET LOCAL DATA FUNCTION")
        LocalFirebaseData.completedPrayers = []
        print("COUNT OF LOCAL FIREBASE DATA COMPLETED PRAYERS: \(LocalFirebaseData.completedPrayers.count)")
        LocalFirebaseData.nextPrayerTitle = "Day 1"
        LocalFirebaseData.name = ""
        LocalFirebaseData.timeTracker = 0.0
        LocalFirebaseData.started = 0
        LocalFirebaseData.completed = 0
        
        self.load10minPrayers(skippingSignIn: false)
    }

}
