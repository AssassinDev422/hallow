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

//WIPHallow - delete commented

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
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("User: \(String(describing: user))")
            if let user = user?.uid {
                self.userID = user
                self.nameOutlet.text = LocalFirebaseData.name
                self.startedNumber.text = String(LocalFirebaseData.started)
                self.completedNumber.text = String(LocalFirebaseData.completed)
                let minutes = LocalFirebaseData.timeTracker / 60.0
                let minutesString = String(format: "%.0f", minutes)
                self.minsNumber.text = minutesString
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
            resetLocalFirebaseData()
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
    
    private func resetLocalFirebaseData() {
        LocalFirebaseData.completedPrayers = []
        print("COUNT OF LOCAL FIREBASE DATA COMPLETED PRAYERS: \(LocalFirebaseData.completedPrayers.count)")
        LocalFirebaseData.nextPrayerTitle = "Day 1"
        LocalFirebaseData.name = ""
        LocalFirebaseData.timeTracker = 0.0
        LocalFirebaseData.started = 0
        LocalFirebaseData.completed = 0
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
}
