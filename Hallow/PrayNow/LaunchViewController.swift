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
        FirebaseUtilities.syncUserData() { }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let _ = user?.uid, let userEmail = user?.email {
                self.loadUser(fromUserEmail: userEmail)
                FirebaseUtilities.loadProfilePicture(byUserEmail: userEmail) { image in
                    self.saveImage(image: image)
                }
            } else {
                self.load10minPrayers(skippingSignIn: false)
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
            self.user = results.map(User.init)[0]
            
            RealmUtilities.signInUser(withUser: self.user) {
                self.load10minPrayers(skippingSignIn: true)
            }
        }
    }
    
    
    //TODO: Clean up these funcs
    private func load10minPrayers(skippingSignIn: Bool) {
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "10 mins") { results in
            let realm = try! Realm() //TODO: change to do, catch try
            var prayers = results.map(PrayerItem.init)
            prayers.sort{$0.title < $1.title}
            let prayers10mins = prayers
            try! realm.write { //TODO: change to do, catch try
                realm.add(prayers)
                realm.add(prayers10mins)
            }
            self.load15minPrayers(skippingSignIn: skippingSignIn)
        }
    }
    
    private func load15minPrayers(skippingSignIn: Bool) {
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "15 mins") { results in
            let realm = try! Realm() //TODO: change to do, catch try
            var prayers15mins = results.map(PrayerItem.init)
            prayers15mins.sort{$0.title < $1.title}
            try! realm.write { //TODO: change to do, catch try
                realm.add(prayers15mins)
            }
            self.load5minPrayers(skippingSignIn: skippingSignIn)
        }
    }
    
    private func load5minPrayers(skippingSignIn: Bool) {
        FirebaseUtilities.loadAllPrayersWithLength(ofType: "prayer", withLength: "5 mins") { results in
            let realm = try! Realm() //TODO: change to do, catch try
            var prayers5mins = results.map(PrayerItem.init)
            prayers5mins.sort{$0.title < $1.title}
            try! realm.write { //TODO: change to do, catch try
                realm.add(prayers5mins)
            }
            
            if skippingSignIn == false {
                self.hideOutlets(shouldHide: false)
            } else {
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
