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
    
    var userConstants: ConstantsItem?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideOutlets(shouldHide: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.userID = user?.uid
                self.loadUserConstantsAndPrayers(fromUser: user!.uid)
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)
            } else {
                self.loadAllPrayers()
                print("no one is logged in")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Functions
    
    private func loadUserConstantsAndPrayers(fromUser userID: String) {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "constants", byUser: userID) { results in
            self.userConstants = results.map(ConstantsItem.init)[0]
            Constants.firebaseDocID = self.userConstants!.docID
            Constants.guide = self.userConstants!.guide
            Constants.isFirstDay = self.userConstants!.isFirstDay
            Constants.hasCompleted = self.userConstants!.hasCompleted
            Constants.hasSeenCompletionScreen = self.userConstants!.hasSeenCompletionScreen
            Constants.hasStartedListening = self.userConstants!.hasStartedListening
            Constants.hasLoggedOutOnce = self.userConstants!.hasLoggedOutOnce
            print("LOADED USER CONSTANTS")
            print("Guide set at: \(Constants.guide)")
            print("Has started listening set at: \(Constants.hasStartedListening)")
            print("Guide pulled at: \(self.userConstants!.guide)")
            print("DocID: \(self.userConstants!.docID)")
            
            self.loadName()
        }
    }
    
    private func loadName() {
        FirebaseUtilities.loadUserData(byUser: self.userID!) {results in
            self.userData = results.map(User.init)[0]
            print("USER DATA IN LAUNCH: \(String(describing: self.userData))")
            LocalFirebaseData.name = self.userData!.name
            
            self.loadStartedPrayers()
        }
    }
    
    private func loadStartedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUser: self.userID!) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            print("STARTED PRAYERS IN LAUNCH: \(self.startedPrayers.count)")
            LocalFirebaseData.started = self.startedPrayers.count
            
            self.loadCompletedPrayers()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("COMPLETED PRAYERS IN LAUNCH: \(self.completedPrayers.count)")
            LocalFirebaseData.completed = self.completedPrayers.count

            self.loadTimeTracker()
        }
    }
    
    private func loadTimeTracker() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUser: self.userID!) {results in
            self.stats = results.map(StatsItem.init)[0]
            LocalFirebaseData.timeTracker = self.stats!.timeInPrayer
            
            self.loadAllPrayers()

        }
    }
    
    private func loadAllPrayers() {
        LocalFirebaseData.prayers = []
        print("LOCAL FIREBASE DATA PRAYERS PRE-LOAD: \(LocalFirebaseData.prayers.count)")
        FirebaseUtilities.loadAllDocumentsByGuideStandardLength(ofType: "prayer", byGuide: Constants.guide) { results in
            LocalFirebaseData.prayers = results.map(PrayerItem.init)
            LocalFirebaseData.prayers.sort{$0.title < $1.title}
            print("LOCAL FIREBASE DATA PRAYERS POST LOAD: \(LocalFirebaseData.prayers.count)")
            
            self.hideOutlets(shouldHide: false)
        }
    }
    
    // Created so when the segue skips past this screen (when user is already logged in) it doesn't show the buttons
    
    private func hideOutlets(shouldHide: Bool) {
        self.signInOutlet.isHidden = shouldHide
        self.signUpOutlet.isHidden = shouldHide
        self.prayerChallengeLabel.isHidden = shouldHide
    }

}
