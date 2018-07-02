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
        loadDisplay()
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func removeReminder(_ sender: Any) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        navigationController?.popViewController(animated: true)
        
        let defaults = UserDefaults.standard
        defaults.set(Date(timeIntervalSince1970: 0), forKey: "reminderTime")
        defaults.synchronize()
    }
    
    @IBAction func updateReminders(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        let reminderSet = defaults.bool(forKey: "reminderSet")
        let firstReminder = defaults.bool(forKey: "firstReminder")
        
        if reminderSet == true {
            if firstReminder == false {
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
            
            let defaults = UserDefaults.standard
            defaults.set(true, forKey: "reminderSet")
            defaults.set(true, forKey: "firstReminder")
            defaults.synchronize()
                        
        }
    }
    
    // MARK: - Functions
    
    
    private func loadDisplay() {
        
        let defaults = UserDefaults.standard
        let reminderSet = defaults.bool(forKey: "reminderSet")
        
        if reminderSet == true {
            
            updateButtonOutlet.setTitle("UPDATE", for: .normal)
            reminderTime.isHidden = false
            removeReminderOutlet.isHidden = false
            
            self.setDisplay()
            
        } else {
            updateButtonOutlet.setTitle("ENABLE REMINDERS", for: .normal)
            reminderTime.isHidden = true
            removeReminderOutlet.isHidden = true
            currentReminderLabel.text = "No reminder currently set"
        }
    }

    private func setDisplay() {
            
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        
        let defaults = UserDefaults.standard
        let reminderTime = defaults.value(forKey: "reminderTime") as! Date
        defaults.synchronize()
        
        let currentTime = formatter.string(from: reminderTime)
        currentReminderLabel.text = "Current reminder set to: \(currentTime)"
    
        self.reminderTime.date = reminderTime
        
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
                print("Something went wrong")
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
        
        
        
        let defaults = UserDefaults.standard
        defaults.set(reminderTime.date, forKey: "reminderTime")
        defaults.synchronize()
        
        print("Set constants value to: \(reminderTime.date)")
        
    }
    
    private func setUpReminder() {
        let center = UNUserNotificationCenter.current()
        
        let identifier = "HallowLocalNotification"
        
        let content = UNMutableNotificationContent()
        content.title = "Quick reminder to pray"
        content.sound = UNNotificationSound.default()
        
        let time = reminderTime.date
        let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Something went wrong on the last step!")
            }
        })
        
        
        let defaults = UserDefaults.standard
        defaults.set(reminderTime.date, forKey: "reminderTime")
        defaults.synchronize()
        
    }
}
