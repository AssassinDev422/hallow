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

class FirstDayReminderViewController: UIViewController {
        
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions

    @IBAction func yesButton(_ sender: Any) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "reminderSet")
        defaults.synchronize()
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
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noReminderSegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                if let nav = destination.selectedViewController as? UINavigationController {
                    if let root = nav.topViewController as? FullJourneyViewController {
                        root.completedSegue = true
                    }
                }
            }
        }
    }
}
