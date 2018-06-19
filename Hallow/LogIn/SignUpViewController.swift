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

// FIXME: Think the error is in not waiting for this thing to save stuff / load before moving on

// TODO: What happens if you try to create the same user with an existing email


class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        nameField.tag = 0
        emailField.delegate = self
        emailField.tag = 1
        passwordField.delegate = self
        passwordField.tag = 2
        
        setUpDoneButton()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            signUp()
            textField.resignFirstResponder()
        }
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        signUp()
    }
    
    func signUp() {
        set(isLoading: true)
        if let name = nameField.text, let emailInit = emailField.text, let password = passwordField.text {
            var email = emailInit
            if email.last == " " {
                email.removeLast()
            }
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                guard let email = authResult?.email, error == nil else {
                    self.set(isLoading: false)
                    self.errorAlert(message: "\(error!.localizedDescription)")
                    return
                }
                
                self.saveDataForSignUp(withUserEmail: email, withName: name, withEmail: emailInit, withPassword: password)
                print("\(email) created")
                self.set(isLoading: false)
            }
        }
    }
    
    // MARK: - Functions
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - First time log in / sign up
    
    private func saveDataForSignUp(withUserEmail userEmail: String, withName name: String, withEmail email: String, withPassword password: String) {
        
        let db = Firestore.firestore()
        db.collection("user").document(userEmail).setData([
            "Name": name,
            "Email": email,
            "Password": password,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added")
                    self.saveStatsSignUp(byUserEmail: userEmail, withTimeInPrayer: 0.0)
                    LocalFirebaseData.name = name
                }
        }
    }
    
    private func saveStatsSignUp(byUserEmail userEmail: String, withTimeInPrayer timeInPrayer: Double) {
        let db = Firestore.firestore()
        db.collection("user").document(userEmail).collection("stats").addDocument(data: [
            "Time in Prayer": timeInPrayer,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added by user: \(userEmail)")
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
                    
                    self.set(isLoading: false)
                    self.performSegue(withIdentifier: "signUpSegue", sender: self)

                }
        }
        Constants.firebaseDocID = ref.documentID
    }
    
    // Sets up loading hud
    
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
        nameField.inputAccessoryView = toolBar
        emailField.inputAccessoryView = toolBar
        passwordField.inputAccessoryView = toolBar
    }
    
    @objc private func doneClicked() {
        view.endEditing(true)
    }
    
}
