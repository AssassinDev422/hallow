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

class LaunchViewController: AudioController {
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var prayerChallengeLabel: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userEmail: String?
        
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideOutlets(shouldHide: true)
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "isFirstOpenOnDevice") != nil {
            print("Not first open on this device")
        } else {
            print("First open on this device")
            defaults.set(Date(timeIntervalSince1970: 0),    forKey: "reminderTime")
            defaults.set(false,                             forKey: "isReminderSet")
            defaults.set(false,                             forKey: "isFirstReminder")
            defaults.set("false",                           forKey: "isFirstOpenOnDevice")
            defaults.synchronize()
        }
        downloadAudio(guide: User.Guide.francis, audioURL: Utilities.backgroundAudioURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user?.uid, let userEmail = user?.email {
                self.loadUser(fromUserEmail: userEmail)
                FirebaseUtilities.syncUserData()
                FirebaseUtilities.loadProfilePicture(byUserEmail: userEmail) { image in
                    self.saveImage(image: image)
                }
            } else {
                self.loadContent() {
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
            guard let user = results.map(User.init).first else {
                print("FIREBASE: Error loading user data")
                return
            }
            RealmUtilities.signInUser(withUser: user) {
                self.loadContent()
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)
            }
        }
    }
    
    private func loadContent(completionBlock: (() -> Void)? = nil) {
        FirebaseUtilities.loadPrayers() { prayers in
            FirebaseUtilities.loadChapters() { chapters in
                RealmUtilities.addPrayers(withPrayers: prayers)
                RealmUtilities.addChapters(withChapters: chapters)
                completionBlock?()
            }
        }
    }
    
    // Created so when the segue skips past this screen (when user is already logged in) it doesn't show the buttons
    private func hideOutlets(shouldHide: Bool) {
        signInButton.isHidden = shouldHide
        signUpButton.isHidden = shouldHide
        prayerChallengeLabel.isHidden = shouldHide
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
