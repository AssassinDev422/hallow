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
    
    @IBOutlet weak var streakNumber: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String? 
    
    var storedUserID: String?
    var storedUserEmail: String?
    
    var newFirebaseDocID: String?

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
            self.userEmail = user?.email
            if let user = user?.uid {
                self.userID = user
                self.nameOutlet.text = LocalFirebaseData.name
                //WIP - self.streakNumber.text = String(LocalFirebaseData.started)
                self.completedNumber.text = String(LocalFirebaseData.completed)
                let minutes = LocalFirebaseData.timeTracker / 60.0
                let minutesString = String(format: "%.0f", minutes)
                self.minsNumber.text = minutesString
                self.streakNumber.text = String(LocalFirebaseData.streak)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Actions

    @IBAction func logOut(_ sender: Any) {
        self.set(isSigningOut: true)
        self.storedUserID = self.userID
        self.storedUserEmail = self.userEmail
        logOutData(ofType: "constants", byUserEmail: self.storedUserEmail!, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
    }
    
    // MARK: - Functions
    
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
            self.errorAlert(message: "\(error.localizedDescription)")
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
        LocalFirebaseData.streak = 0
        
        self.set(isSigningOut: false)
        self.performSegue(withIdentifier: "signOutSegue", sender: self)
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Sets up hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .extraLight)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    private func set(isSigningOut: Bool) {
        if isSigningOut {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: false)
        }
    }
    
}
