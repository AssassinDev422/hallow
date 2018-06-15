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
                self.loadUserConstants(fromUser: user!.uid)
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)
            } else {
                self.hideOutlets(shouldHide: false)
                print("no one is logged in")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Functions
    
    private func loadUserConstants(fromUser userID: String) {
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
        }
    }
    
    // Created so when the segue skips past this screen (when user is already logged in) it doesn't show the buttons
    
    private func hideOutlets(shouldHide: Bool) {
        self.signInOutlet.isHidden = shouldHide
        self.signUpOutlet.isHidden = shouldHide
        self.prayerChallengeLabel.isHidden = shouldHide
    }

}
