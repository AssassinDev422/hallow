//
//  CompletedViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class CompletedViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
        
    // MARK: - Life cycle
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
            if let email = self.userEmail {
                FirebaseUtilities.updateConstantsFile(withDocID: Constants.firebaseDocID, byUserEmail: email, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
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
    
    // MARK: - Actions

    @IBAction func addToListButton(_ sender: Any) {
        FirebaseUtilities.preOrderResponse(ofType: "preOrderResponse", byUserEmail: self.userEmail!, withEntry: "Yes")
        performSegue(withIdentifier: "repeatPrayerSegue", sender: self)
    }
    
    @IBAction func noThanksButton(_ sender: Any) {
        FirebaseUtilities.preOrderResponse(ofType: "preOrderResponse", byUserEmail: self.userEmail!, withEntry: "No")
        performSegue(withIdentifier: "repeatPrayerSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "repeatPrayerSegue", let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
        }
    }

}
