//
//  ReflectViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//


import UIKit
import FirebaseFirestore
import Firebase
import RealmSwift

class ReflectViewController: JournalBaseViewController {

    @IBOutlet weak var textField: UITextView!
    
    var user = User()
    var prayerTitle: String?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 0.5
        textField!.layer.borderColor = UIColor.white.cgColor
        textField.delegate = self
        setUpDoneButton(textView: textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error in will appear of reflect")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of reflect")
        }
        ReachabilityManager.shared.addListener(listener: self)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }

    // MARK: - Actions
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        reflectSegue()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func exitButton(_ sender: Any) {
        reflectSegue()
    }
    
    private func save() {
        guard let entry = textField.text, let prayerTitle = prayerTitle else {
            print("Error in save")
            return
        }
        let journalEntry = JournalEntry()
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yy"
        let date = formatter.string(from: NSDate() as Date)
        let dateStored = Date(timeIntervalSinceNow: 0.00)
        journalEntry.date = date
        journalEntry.dateStored = dateStored
        journalEntry.docID = RealmUtilities.calcDocID(withUser: user) + 1
        journalEntry.entry = entry
        journalEntry.prayerTitle = prayerTitle
        journalEntry.userEmail = user.email
        RealmUtilities.saveJournalEntry(withEntry: journalEntry)
        reflectSegue()
    }
        
    private func reflectSegue() {
        if user.isFirstDay {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            RealmUtilities.updateIsFirstDay(withIsFirstDay: false)
        } else {
            performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
        }
    }
   
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
