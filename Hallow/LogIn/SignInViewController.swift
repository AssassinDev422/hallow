//
//  SignInViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/11/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SignInViewController: LogInBaseViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var userConstants: ConstantsItem?
    
    var userID: String?
    var userEmail: String?
    
    var userData: User?
    var startedPrayers: [PrayerTracking] = []
    var completedPrayers: [PrayerTracking] = []
    var stats: StatsItem?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
        
        setUpDoneButton(textField: emailField)
        setUpDoneButton(textField: passwordField)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            signIn()
            passwordField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func signInButton(_ sender: Any) {
        signIn()
    }
    
    private func signIn() {
        showLightHud()
        if let emailInit = self.emailField.text, let password = self.passwordField.text {
            var email = emailInit
            if email.last == " " {
                email.removeLast()
            }
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                guard let userID = user?.uid, let userEmail = user?.email, error == nil else {
                    Utilities.errorAlert(message: "\(error?.localizedDescription ?? "Error signing in")", viewController: self)
                    self.dismissHud()
                    return
                }
                self.userID = userID
                self.userEmail = userEmail
                self.loadUserConstants(fromUserEmail: userEmail)
                FirebaseUtilities.loadProfilePicture(byUserEmail: userEmail)
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadUserConstants(fromUserEmail userEmail: String) {
        guard let email = self.userEmail else {
            Utilities.errorAlert(message: "No user signed in", viewController: self)
            return
        }
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "constants", byUserEmail: email) { results in
            self.userConstants = results.map(ConstantsItem.init)[0]
            guard let userConstants = self.userConstants else {
                Utilities.errorAlert(message: "Error downloaded user data", viewController: self)
                return
            }
            Constants.firebaseDocID = userConstants.docID
            Constants.guide = userConstants.guide
            Constants.isFirstDay = userConstants.isFirstDay
            Constants.hasCompleted = userConstants.hasCompleted
            Constants.hasSeenCompletionScreen = userConstants.hasSeenCompletionScreen
            Constants.hasStartedListening = userConstants.hasStartedListening
            Constants.hasLoggedOutOnce = userConstants.hasLoggedOutOnce
            
            self.loadName()
        }
    }
    
    private func loadName() {
        guard let userEmail = self.userEmail else {
            Utilities.errorAlert(message: "Error loading data", viewController: self)
            return
        }
        FirebaseUtilities.loadUserData(byUserEmail: userEmail) {results in
            self.userData = results.map(User.init)[0]
            
            guard let userData = self.userData else {
                Utilities.errorAlert(message: "Error loading data", viewController: self)
                return
            }
            
            LocalFirebaseData.name = userData.name
            self.loadStartedPrayers()
        }
    }
    
    private func loadStartedPrayers() {
        guard let userEmail = self.userEmail else {
            Utilities.errorAlert(message: "Error loading data", viewController: self)
            return
        }
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUserEmail: userEmail) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            LocalFirebaseData.started = self.startedPrayers.count
            
            self.loadCompletedPrayers()
        }
    }
    
    private func loadCompletedPrayers() {
        guard let userEmail = self.userEmail else {
            Utilities.errorAlert(message: "Error loading data", viewController: self)
            return
        }
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUserEmail: userEmail) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            LocalFirebaseData.completed = self.completedPrayers.count
            
            var date: [Date] = []
            for completedPrayer in self.completedPrayers {
                date.append(completedPrayer.dateStored)
            }
            LocalFirebaseData.mostRecentPrayerDate = date.sorted()[date.count - 1]
            
            self.loadTimeTracker()
        }
    }
    
    private func loadTimeTracker() {
        guard let userEmail = self.userEmail else {
            Utilities.errorAlert(message: "Error loading data", viewController: self)
            return
        }
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUserEmail: userEmail) {results in
            self.stats = results.map(StatsItem.init)[0]
            
            guard let stats = self.stats else {
                Utilities.errorAlert(message: "Error loading data", viewController: self)
                return
            }
            
            LocalFirebaseData.timeTracker = stats.timeInPrayer
            LocalFirebaseData.streak = stats.streak
            
            self.dismissHud()
            self.performSegue(withIdentifier: "signInSegue", sender: self)
        }
    }
    
}
