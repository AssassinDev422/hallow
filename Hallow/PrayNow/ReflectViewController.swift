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

class ReflectViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textField: UITextView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
    
    var frame: CGRect?
    
    var prayerTitle: String?


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 0.5
        textField!.layer.borderColor = UIColor.white.cgColor
        
        textField.delegate = self
                
        setUpDoneButton()

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
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }

    // MARK: - Actions
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        reflectSegue()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        save()
    }
    @IBAction func exitButton(_ sender: Any) {
        if Constants.isFirstDay == true {
            Constants.isFirstDay = false
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
        } else {
            if Constants.hasCompleted == false {
                performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
            } else {
                if Constants.hasSeenCompletionScreen == false {
                    Constants.hasSeenCompletionScreen = true
                    performSegue(withIdentifier: "completedSegue", sender: self)
                } else {
                    performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
                }
            }
        }
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
        performSegue(withIdentifier: "returnFromReflectToAudioSegue", sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "isNotFirstDaySegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
            }
        } else if segue.identifier == "exitReflectSegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Did begin editing")
        self.frame = textView.frame
        var newFrame = self.frame!
        newFrame.size.height = self.frame!.height / 2.5
        textView.frame = newFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.frame = self.frame!
    }
    
}
