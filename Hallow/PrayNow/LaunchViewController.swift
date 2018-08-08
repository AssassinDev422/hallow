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
import RealmSwift

class LaunchViewController: BaseViewController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var prayerChallengeLabel: UILabel!
    
    var user = User()
    var handle: AuthStateDidChangeListenerHandle?
    var userEmail: String?
        
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideOutlets(shouldHide: true)
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "firstOpenOnDevice") != nil {
            print("Not first open on this device")
        } else {
            print("First open on this device")
            defaults.set(Date(timeIntervalSince1970: 0),    forKey: "reminderTime")
            defaults.set(false,                             forKey: "reminderSet")
            defaults.set(false,                             forKey: "firstReminder")
            defaults.set(false,                             forKey: "iPhoneX")
            defaults.set("false",                           forKey: "firstOpenOnDevice")
            defaults.synchronize()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        overrideLogOut()
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user?.uid, let userEmail = user?.email {
                self.loadUser(fromUserEmail: userEmail)
                FirebaseUtilities.syncUserData() { }
                FirebaseUtilities.loadProfilePicture(byUserEmail: userEmail) { image in
                    self.saveImage(image: image)
                }
            } else {
                FirebaseUtilities.loadAllPrayers() { prayers in
                    RealmUtilities.addPrayers(withPrayers: prayers)
                    self.hideOutlets(shouldHide: false)
                }
                print("no one is logged in")
            }
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {
            print("Error with handle")
            return
        }
        Auth.auth().removeStateDidChangeListener(handle)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Functions
    
    private func loadUser(fromUserEmail userEmail: String) {
        FirebaseUtilities.loadUserData(byUserEmail: userEmail) { results in
            guard let results = results.map(User.init).first else {
                print("FIREBASE: Error loading user data")
                return
            }
            self.user = results
            RealmUtilities.signInUser(withUser: self.user) {
                FirebaseUtilities.loadAllPrayers() { prayers in
                    RealmUtilities.addPrayers(withPrayers: prayers)
                }
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)
            }
        }
    }
    
    // Created so when the segue skips past this screen (when user is already logged in) it doesn't show the buttons
    private func hideOutlets(shouldHide: Bool) {
        self.signInButton.isHidden = shouldHide
        self.signUpButton.isHidden = shouldHide
        self.prayerChallengeLabel.isHidden = shouldHide
    }
    
    // For testing - if need to override log out - call function after log in in viewWillAppear and run twice
    private func overrideLogOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error.localizedDescription)
        }
        RealmUtilities.deleteUser()
    }

}
