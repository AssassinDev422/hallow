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
    
    @IBOutlet weak var minsNumber: UILabel!
    @IBOutlet weak var completedNumber: UILabel!
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    @IBOutlet weak var minsLabel: UILabel!
    @IBOutlet weak var startedLabel: UILabel!
    @IBOutlet weak var startedNumber: UILabel!
    
    @IBOutlet weak var logOutOutlet: UIButton!
    var completedPrayers: [PrayerTracking] = []
    var stats: StatsItem?
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    // MARK: - Life cycle
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        set(isLoading: true)
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
            self.completedNumber.text = String(self.completedPrayers.count)
            if self.numberLoading == 1 {
                self.set(isLoading: false)
            } else {
                self.numberLoading = 1
            }
        }
    }
    
    private func updateTimeInPrayer() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUser: self.userID!) {results in
            self.stats = results.map(StatsItem.init)[0]  
            let minutes = (self.stats?.timeInPrayer)! / 60.0
            let minutesString = String(format: "%.0f", minutes)
            self.minsNumber.text = minutesString
            if self.numberLoading == 1 {
                self.set(isLoading: false)
            } else {
                self.numberLoading = 1
            }
        }
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Sets up loading hud
    
    var numberLoading = 2
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    private func set(isLoading: Bool) {
        if isLoading {
            self.hud.show(in: view, animated: false)
            self.minsNumber.isHidden = true
            self.minsLabel.isHidden = true
            self.nameOutlet.isHidden = true
            self.completedLabel.isHidden = true
            self.completedNumber.isHidden = true
        } else {
            self.hud.dismiss(animated: false)
            self.minsNumber.isHidden = false
            self.minsLabel.isHidden = false
            self.nameOutlet.isHidden = false
            self.completedLabel.isHidden = false
            self.completedNumber.isHidden = false
        }
    }

}
