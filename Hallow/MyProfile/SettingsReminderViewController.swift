//
//  SettingsReminderViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/28/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import UserNotifications

class SettingsReminderViewController: UIViewController {

    @IBOutlet weak var reminderTime: UIDatePicker!
    @IBOutlet weak var currentReminderLabel: UILabel!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Reminders"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        figureOutCurrentReminder()
    }
    
    // MARK: - Actions
    
    @IBAction func removeReminder(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        navigationController?.popViewController(animated: true)
        Constants.reminderTime = Date(timeIntervalSince1970: 0)
    }
    
    @IBAction func updateReminders(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        setUpReminder()
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Functions
    
    
    private func figureOutCurrentReminder() {
        let compare = Date(timeIntervalSince1970: 1)
        if Constants.reminderTime < compare {
            currentReminderLabel.text = "No reminder currently set"
        } else {
            reminderTime.date = Constants.reminderTime
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let currentTime = formatter.string(from: Constants.reminderTime)
            currentReminderLabel.text = "Current reminder set to: \(currentTime)"
            print("\(String(describing: currentReminderLabel.text))")
        }
    }
    
    private func setUpReminder() {
        let center = UNUserNotificationCenter.current()
        
        let identifier = "HallowLocalNotification"
        
        let content = UNMutableNotificationContent()
        content.title = "Quick reminder to pray"
        content.body = "Click here to open up Hallow"
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
    }
}
