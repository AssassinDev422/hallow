//
//  FirstDayReminderViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/28/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import UserNotifications

class FirstDayReminderViewController: UIViewController {
    
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
                print("Something #2 went wrong")
            }
        }
    }
    
    // MARK: - NAVIGATION
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "noReminderSegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                print("prepare for segue happened")
            }
        }
    }
    
}
