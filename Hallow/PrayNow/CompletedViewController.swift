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
    
    // MARK: - Life cycle
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Actions

    @IBAction func addToListButton(_ sender: Any) {
        FirebaseUtilities.preOrderResponse(ofType: "preOrderResponse", byUserID: self.userID!, withEntry: "Yes")
        performSegue(withIdentifier: "repeatPrayerSegue", sender: self)
    }
    
    @IBAction func noThanksButton(_ sender: Any) {
        FirebaseUtilities.preOrderResponse(ofType: "preOrderResponse", byUserID: self.userID!, withEntry: "No")
        performSegue(withIdentifier: "repeatPrayerSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "repeatPrayerSegue", let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                print("prepare for segue happened")
        }
    }

}
