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

class ReflectViewController: JournalBaseViewController {

    @IBOutlet weak var textField: UITextView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
    
    var prayerTitle: String?


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 0.5
        textField!.layer.borderColor = UIColor.white.cgColor
        
        textField.delegate = self
                
        setUpDoneButton(textView: textField)

    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
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
        let entry = textField!.text
    
        FirebaseUtilities.saveReflection(ofType: "journal", byUserEmail: self.userEmail!, withEntry: entry!, withTitle: prayerTitle!)
        
        reflectSegue()

    }
    
    private func reflectSegue() {
        if Constants.isFirstDay == true {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            Constants.isFirstDay = false
        } else {
            if Constants.hasCompleted == false {
                performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
            } else {
                if Constants.hasSeenCompletionScreen == false {
                    performSegue(withIdentifier: "completedSegue", sender: self)
                    Constants.hasSeenCompletionScreen = true
                } else {
                    performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
                }
            }
        }
    }
   
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "isNotFirstDaySegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
            }
        } else if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
        }
    }
        
}
