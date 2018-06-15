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
    @IBOutlet weak var updateButtonOutlet: UIButton!
    
    @IBOutlet weak var removeReminderOutlet: UIButton!
        
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "My Reminders"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpDisplay()
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
        if Constants.reminderSet == true {
            if Constants.firstReminder == false {
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
                center.removeAllPendingNotificationRequests()
                setUpReminder()
                navigationController?.popViewController(animated: true)
            } else {
                setUpFirstReminder()
                navigationController?.popViewController(animated: true)
            }
        } else {
            allowFirstReminder()
            Constants.reminderSet = true
            Constants.firstReminder = true
        }
    }
    
    // MARK: - Functions
    
    
    private func setUpDisplay() {
        if Constants.reminderSet == true {
            
            updateButtonOutlet.setTitle("UPDATE", for: .normal)
            reminderTime.isHidden = false
            removeReminderOutlet.isHidden = false
            
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
            
        } else {
            updateButtonOutlet.setTitle("ENABLE REMINDERS", for: .normal)
            reminderTime.isHidden = true
            removeReminderOutlet.isHidden = true
            currentReminderLabel.text = "No reminder currently set"
        }
    }
    
    private func allowFirstReminder() {
        print("allowFirstReminder run")
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
        updateButtonOutlet.setTitle("UPDATE", for: .normal)
        reminderTime.isHidden = false
        removeReminderOutlet.isHidden = false
    }
    
    private func setUpFirstReminder() {
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
