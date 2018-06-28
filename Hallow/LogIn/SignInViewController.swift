//
//  SignInViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/11/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var userConstants: ConstantsItem?
    
    var userID: String?
    var userEmail: String?
    
    var userData: User?
    var startedPrayers: [PrayerTracking] = []
    var completedPrayers: [PrayerTracking] = []
    var stats: StatsItem?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        emailField.tag = 1
        passwordField.delegate = self
        passwordField.tag = 2
        
        setUpDoneButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            signIn()
            textField.resignFirstResponder()
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signInButton(_ sender: Any) {
        signIn()
    }
    
    private func signIn() {
        set(isLoading: true)
        if let emailInit = self.emailField.text, let password = self.passwordField.text {
            var email = emailInit
            if email.last == " " {
                email.removeLast()
            }
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    self.errorAlert(message: "\(error.localizedDescription)")
                    self.set(isLoading: false)
                    return
                } else {
                    self.userID = user?.uid
                    self.userEmail = user?.email
                    self.loadUserConstants(fromUserEmail: self.userEmail!)
                    FirebaseUtilities.loadProfilePicture(byUserEmail: self.userEmail!)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadUserConstants(fromUserEmail userEmail: String) {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "constants", byUserEmail: self.userEmail!) { results in
            self.userConstants = results.map(ConstantsItem.init)[0]
            Constants.firebaseDocID = self.userConstants!.docID
            Constants.guide = self.userConstants!.guide
            Constants.isFirstDay = self.userConstants!.isFirstDay
            Constants.hasCompleted = self.userConstants!.hasCompleted
            Constants.hasSeenCompletionScreen = self.userConstants!.hasSeenCompletionScreen
            Constants.hasStartedListening = self.userConstants!.hasStartedListening
            Constants.hasLoggedOutOnce = self.userConstants!.hasLoggedOutOnce
            
            self.loadName()
        }
    }
    
    private func loadName() {
        FirebaseUtilities.loadUserData(byUserEmail: self.userEmail!) {results in
            self.userData = results.map(User.init)[0]
            LocalFirebaseData.name = self.userData!.name
            
            self.loadStartedPrayers()
        }
    }
    
    private func loadStartedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "startedPrayers", byUserEmail: self.userEmail!) {results in
            self.startedPrayers = results.map(PrayerTracking.init)
            LocalFirebaseData.started = self.startedPrayers.count
            
            self.loadCompletedPrayers()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUserEmail: self.userEmail!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            LocalFirebaseData.completed = self.completedPrayers.count
            
            var date: [Date] = []
            for completedPrayer in self.completedPrayers {
                date.append(completedPrayer.dateStored)
            }
            LocalFirebaseData.mostRecentPrayerDate = date.sorted()[date.count - 1]
            
            self.loadTimeTracker()
        }
    }
    
    private func loadTimeTracker() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUserEmail: self.userEmail!) {results in
            self.stats = results.map(StatsItem.init)[0]
            LocalFirebaseData.timeTracker = self.stats!.timeInPrayer
            LocalFirebaseData.streak = self.stats!.streak
            
            self.set(isLoading: false)
            self.performSegue(withIdentifier: "signInSegue", sender: self)
        }
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Sets up is loading hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    private func set(isLoading: Bool) {
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: false)
        }
    }
    
    // MARK: - Navigation
    // Unwind
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
    }
    
    // MARK: - Design
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    // Add done button to keyboard
    
    private func setUpDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        emailField.inputAccessoryView = toolBar
        passwordField.inputAccessoryView = toolBar
    }
    
    @objc private func doneClicked() {
        view.endEditing(true)
    }
    
}
