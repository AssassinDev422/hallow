//
//  MyProfileViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

//TODO: Add privacy, terms and conditions

class MyProfileViewController: UIViewController {

    @IBOutlet weak var topBorderOutlet: UIImageView!
    @IBOutlet weak var haloOutlet: UIImageView!
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var containerOutlet: UIView!
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var logOutOutlet: UIButton!

    @IBOutlet weak var minsNumber: UILabel!
    @IBOutlet weak var minsLabel: UILabel!

    @IBOutlet weak var completedNumber: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var startedNumber: UILabel!
    @IBOutlet weak var startedLabel: UILabel!
    
    var startedPrayers: [PrayerTracking] = []
    var completedPrayers: [PrayerTracking] = []
    var userData: User?
    var stats: StatsItem?
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    var numberLoading = 4
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "fadedPink")
    }

    // Firebase listener

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        set(isLoading: true)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("User: \(String(describing: user))")
            if let user = user?.uid {
                self.userID = user
                self.numberLoading = 4
                self.loadName()
                self.loadStartedPrayers()
                self.loadCompletedPrayers()
                self.updateTimeInPrayer()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Actions

    @IBAction func logOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            saveAndResetConstants()
            performSegue(withIdentifier: "signOutSegue", sender: self)
        } catch let error {
            print(error.localizedDescription)
            self.errorAlert(message: "\(error.localizedDescription)")
        }
    }
    
    // MARK: - Functions
        
    private func saveAndResetConstants() {
        if Constants.hasLoggedOutOnce == true {
            FirebaseUtilities.deleteFile(ofType: "constants", byUser: self.userID!, withID: Constants.firebaseDocID)
            FirebaseUtilities.saveAndResetUserConstants(ofType: "constants", byUserID: self.userID!, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
            print("SAVED AND DELETED USER CONSTANTS")

        } else {
            FirebaseUtilities.saveAndResetUserConstants(ofType: "constants", byUserID: self.userID!, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: true)
            print("JUST SAVED USER CONSTANTS")
        }
        
    }
    
    private func loadName() {
        FirebaseUtilities.loadUserData(loadField: "Name", byUser: self.userID!) {results in
            self.userData = results.map(User.init)[0]
            print("User data: \(String(describing: self.userData))")
            self.nameOutlet.text = String(self.userData!.name)
            if self.numberLoading < 2 {
                self.set(isLoading: false)
            } else {
                self.numberLoading -= 1
            }
        }
        
        
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUser: self.userID!) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            print("Started prayers: \(self.startedPrayers.count)")
            self.startedNumber.text = String(self.startedPrayers.count)
            if self.numberLoading < 2 {
                self.set(isLoading: false)
            } else {
                self.numberLoading -= 1
            }
        }
    }
    
    private func loadStartedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUser: self.userID!) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            print("Started prayers: \(self.startedPrayers.count)")
            self.startedNumber.text = String(self.startedPrayers.count)
            if self.numberLoading < 2 {
                self.set(isLoading: false)
            } else {
                self.numberLoading -= 1
            }
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("Completed prayers: \(self.completedPrayers.count)")
            self.completedNumber.text = String(self.completedPrayers.count)
            if self.numberLoading < 2 {
                self.set(isLoading: false)
            } else {
                self.numberLoading -= 1
            }
        }
    }
    
    private func updateTimeInPrayer() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUser: self.userID!) {results in
            self.stats = results.map(StatsItem.init)[0]  
            let minutes = (self.stats?.timeInPrayer)! / 60.0
            let minutesString = String(format: "%.0f", minutes)
            self.minsNumber.text = minutesString
            if self.numberLoading < 2 {
                self.set(isLoading: false)
            } else {
                self.numberLoading -= 1
            }
        }
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Sets up loading hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    private func set(isLoading: Bool) {
        self.topBorderOutlet.isHidden = isLoading
        self.profileOutlet.isHidden = isLoading
        self.haloOutlet.isHidden = isLoading
        self.containerOutlet.isHidden = isLoading
        self.nameOutlet.isHidden = isLoading
        self.logOutOutlet.isHidden = isLoading
        self.minsNumber.isHidden = isLoading
        self.minsLabel.isHidden = isLoading
        self.startedNumber.isHidden = isLoading
        self.startedLabel.isHidden = isLoading
        self.completedNumber.isHidden = isLoading
        self.completedLabel.isHidden = isLoading
        
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: false)
        }
    }

}
