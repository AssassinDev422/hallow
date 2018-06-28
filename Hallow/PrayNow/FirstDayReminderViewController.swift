//
//  FirstDayReminderViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/28/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import JGProgressHUD

class FirstDayReminderViewController: UIViewController {
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
        
    // MARK: - Life cycle
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userEmail = user?.email
            if let user = user?.uid, let email = self.userEmail {
                self.userID = user
                FirebaseUtilities.updateConstantsFile(withDocID: Constants.firebaseDocID, byUserEmail: email, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
            }
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions

    @IBAction func yesButton(_ sender: Any) {
        Constants.reminderSet = true
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound]
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("Something went wrong")
            }
        }
    }
    
    // MARK: - Functions
    // TODO: - Can probably combine with functions from myProfile into Firebase Utilities file
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noReminderSegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
            }
        }
    }
    
}
