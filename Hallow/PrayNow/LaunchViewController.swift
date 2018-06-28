//
//  LaunchViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import Reachability

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.userID = user?.uid
                self.userEmail = user?.email
                self.loadUserConstantsAndPrayers(fromUserEmail: self.userEmail!)
                FirebaseUtilities.loadProfilePicture(byUserEmail: self.userEmail!)
            } else {
                self.load10minPrayers(skippingSignIn: false)
                print("no one is logged in")
            }
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
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
            
            self.loadName()
        }
    }
    
    private func loadName() {
        FirebaseUtilities.loadUserData(byUserEmail: self.userEmail!) {results in
            self.userData = results.map(User.init)[0]
            LocalFirebaseData.name = self.userData!.name
            
            self.loadStartedPrayers()
        }
    }
    
    private func loadStartedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUserEmail: self.userEmail!) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            LocalFirebaseData.started = self.startedPrayers.count
            
            self.loadCompletedPrayers()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUserEmail: self.userEmail!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("COMPLETED PRAYERS IN LAUNCH: \(self.completedPrayers.count)")
            LocalFirebaseData.completed = self.completedPrayers.count
            
            if self.completedPrayers.count > 0 {
                var date: [Date] = []
                for completedPrayer in self.completedPrayers {
                    date.append(completedPrayer.dateStored)
                }
                LocalFirebaseData.mostRecentPrayerDate = date.sorted()[date.count - 1]
            }
            

            self.loadTimeTracker()
        }
    }
    
    private func loadTimeTracker() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUserEmail: self.userEmail!) {results in
            self.stats = results.map(StatsItem.init)[0]
            LocalFirebaseData.timeTracker = self.stats!.timeInPrayer
            LocalFirebaseData.streak = self.stats!.streak
            
            self.load10minPrayers(skippingSignIn: true)

        }
    }
    
    private func load10minPrayers(skippingSignIn: Bool) {
        LocalFirebaseData.prayers = []
        LocalFirebaseData.prayers10mins = []
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "10 mins") { results in
            LocalFirebaseData.prayers = results.map(PrayerItem.init)
            LocalFirebaseData.prayers.sort{$0.title < $1.title}
            LocalFirebaseData.prayers10mins = LocalFirebaseData.prayers
            
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
    

}
