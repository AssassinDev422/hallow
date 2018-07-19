//
//  SignUpViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/11/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import JGProgressHUD

class SignUpViewController: LogInBaseViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        setUpDoneButton(textField: nameField)
        setUpDoneButton(textField: emailField)
        setUpDoneButton(textField: passwordField)
        
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
        if textField == nameField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            signUp()
            passwordField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        signUp()
    }
    
    func signUp() {
        showLightHud()
        if let name = nameField.text, let emailInit = emailField.text, let password = passwordField.text {
            var email = emailInit
            if email.last == " " {
                email.removeLast()
            }
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                guard let email = authResult?.email, error == nil else {
                    self.dismissHud()
                    Utilities.errorAlert(message: "\(error?.localizedDescription ?? "Error signing up")", viewController: self)
                    return
                }
                
                self.saveDataForSignUp(withUserEmail: email, withName: name, withEmail: emailInit)
                LocalFirebaseData.userEmail = email
                self.dismissHud()
            }
        }
    }
        
    // MARK: - First time log in / sign up
    
    private func saveDataForSignUp(withUserEmail userEmail: String, withName name: String, withEmail email: String) {
        
        let db = Firestore.firestore()
        db.collection("user").document(userEmail).setData([
            "Name": name,
            "Email": email,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                    self.saveStatsSignUp(byUserEmail: userEmail, withTimeInPrayer: 0.0, withStreak: 0)
                    LocalFirebaseData.name = name
                }
        }
    }
    
    private func saveStatsSignUp(byUserEmail userEmail: String, withTimeInPrayer timeInPrayer: Double, withStreak streak: Int) {
        let db = Firestore.firestore()
        db.collection("user").document(userEmail).collection("stats").addDocument(data: [
            "Time in Prayer": timeInPrayer,
            "Streak": streak
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added by user: \(userEmail)")
                    
                    LocalFirebaseData.timeTracker = 0.00
                    LocalFirebaseData.mostRecentPrayerDate = Date(timeIntervalSince1970: 0)
                    
                    self.saveSignUpConstants(ofType: "constants", byUserEmail: userEmail)
                }
        }
    }
    
    private func saveSignUpConstants(ofType type: String, byUserEmail userEmail: String) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        let ref = db.collection("user").document(userEmail).collection(type).addDocument(data: [
            "Date Stored": dateStored,
            "guide": "Francis",
            "isFirstDay": true,
            "hasCompleted": false,
            "hasSeenCompletionScreen": false,
            "hasStartedListening": false,
            "hasLoggedOutOnce": false,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(userEmail)")
                    Constants.guide = "Francis"
                    Constants.isFirstDay = true
                    Constants.hasCompleted = false
                    Constants.hasSeenCompletionScreen = false
                    Constants.hasStartedListening = false
                    Constants.hasLoggedOutOnce = false
                    
                    self.dismissHud()
                    self.performSegue(withIdentifier: "signUpSegue", sender: self)

                }
        }
        Constants.firebaseDocID = ref.documentID
    }
    
}
