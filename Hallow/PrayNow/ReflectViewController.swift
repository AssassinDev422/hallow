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

class ReflectViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 0.5
        textField!.layer.borderColor = UIColor.white.cgColor
                
        setUpDoneButton()

    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("REFLECT VIEW WILL APPEAR*************")
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid  //FIXME: Thread error - found nil when clicking logout when user was unwrapped "!"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("REFLECT VIEW DISAPPEARED*************")
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    // MARK: - Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        save()
    }
    @IBAction func exitButton(_ sender: Any) {
        if Constants.isFirstDay == true {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            Constants.isFirstDay = false
        } else if Constants.hasCompleted == false {
            performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
        } else if Constants.hasCompleted == true {
            performSegue(withIdentifier: "completedSegue", sender: self)
        }
    }
    
    private func save() {
        let entry = textField!.text
    
        FirebaseUtilities.saveReflection(ofType: "journal", byUserID: self.userID!, withEntry: entry!)
    
        if Constants.isFirstDay == true {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            Constants.isFirstDay = false
        } else if Constants.hasCompleted == false {
            performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
        } else if Constants.hasCompleted == true {
            if Constants.hasSeenCompletionScreen == true {
                performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
            } else {
                performSegue(withIdentifier: "completedSegue", sender: self)
                Constants.hasSeenCompletionScreen = true
            }
        }
    }
   
    @IBAction func backButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "returnFromReflectToAudioSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "isNotFirstDaySegue" {
            print("*************segue identifier is alright - not first")
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                print("prepare for segue happened")
            }
        } else if segue.identifier == "exitReflectSegue" {
            print("*************segue identifier exiting reflect segue")
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                print("prepare for segue happened")
            }
        }
    }
    
    // MARK: - Design
    
    // Add done button to keyboard
    
    private func setUpDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
    }
    
    @objc private func doneClicked() {
        view.endEditing(true)
    }
    
}
