//
//  MyProfileViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

//TODO: Add privacy, terms and conditions

class MyProfileViewController: UIViewController {
    
    @IBOutlet weak var timeInPrayer: UILabel!
    @IBOutlet weak var prayerSessionCount: UILabel!
    
    var completedPrayers: [PrayerTracking] = []
    var stats: StatsItem?
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    // MARK: - Life cycle
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            print("User: \(String(describing: user))")
            if let user = user?.uid {
                self.userID = user
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
        performSegue(withIdentifier: "signOutSegue", sender: self)
        } catch let error {
            print(error.localizedDescription)
            self.errorAlert(message: "\(error.localizedDescription)")
        }
    }
    
    // MARK: - Functions
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("Completed prayers: \(self.completedPrayers.count)")
            self.prayerSessionCount.text = String(self.completedPrayers.count)
        }
    }
    
    private func updateTimeInPrayer() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUser: self.userID!) {results in
            self.stats = results.map(StatsItem.init)[0]  
            let minutes = (self.stats?.timeInPrayer)! / 60.0
            let minutesString = String(format: "%.0f", minutes)
            self.timeInPrayer.text = minutesString
        }
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }

}
