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
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        emailField.tag = 1
        passwordField.delegate = self
        passwordField.tag = 2
        
        setUpDoneButton()

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
        if let email = self.emailField.text, let password = self.passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if let error = error {
                    self.errorAlert(message: "\(error.localizedDescription)")
                    self.set(isLoading: false)
                    return
                } else {
                    self.loadUserConstants(fromUser: user!.uid)
                    self.set(isLoading: false)
                    self.performSegue(withIdentifier: "signInSegue", sender: self)
                }
            }
        }
    }
    
    // MARK: - Functions
    
    private func loadUserConstants(fromUser userID: String) {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "constants", byUser: userID) { results in
            self.userConstants = results.map(ConstantsItem.init)[0]
            Constants.firebaseDocID = self.userConstants!.docID
            Constants.guide = self.userConstants!.guide
            Constants.isFirstDay = self.userConstants!.isFirstDay
            Constants.hasCompleted = self.userConstants!.hasCompleted
            Constants.hasSeenCompletionScreen = self.userConstants!.hasSeenCompletionScreen
            Constants.hasStartedListening = self.userConstants!.hasStartedListening
            Constants.hasLoggedOutOnce = self.userConstants!.hasLoggedOutOnce
            print("LOADED USER CONSTANTS")
            print("Guide set at: \(Constants.guide)")
            print("Has started listening set at: \(Constants.hasStartedListening)")
            print("Guide pulled at: \(self.userConstants!.guide)")
            print("DocID: \(self.userConstants!.docID)")
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
