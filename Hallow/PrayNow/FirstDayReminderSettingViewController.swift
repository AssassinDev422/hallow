//
//  FirstDayReminderSettingViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/28/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import UserNotifications


class FirstDayReminderSettingViewController: UIViewController {

    @IBOutlet weak var reminderTime: UIDatePicker!
    
    // MARK: - Actions
    
    @IBAction func setUpReminderButton(_ sender: Any) {
        setUpReminder()
    }
    @IBAction func nevermindButton(_ sender: Any) {
        performSegue(withIdentifier: "finishFirstDaySegue", sender: self)
    }
    
    // MARK: - Functions
    
    private func setUpReminder() {
        let center = UNUserNotificationCenter.current()
        
        let identifier = "HallowLocalNotification"
        
        let content = UNMutableNotificationContent()
        content.title = "Quick reminder to pray"
        content.body = "Clikc here to open up Hallow"
        content.sound = UNNotificationSound.default()
        
        let time = reminderTime.date
        let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        print("triggerDaily value: \(triggerDaily)")
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Something went wrong on the last step!")
            }
        })

        Constants.reminderTime = reminderTime.date
        print("Set constants value to: \(Constants.reminderTime)")
        performSegue(withIdentifier: "finishFirstDaySegue", sender: self)

    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishFirstDaySegue" {
            print("*************segue identifier finishing first day segue")
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                print("prepare for segue happened")
            }
        }
    }
    
}
