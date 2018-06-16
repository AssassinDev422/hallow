//
//  SignUpViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/11/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

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
        if let name = nameField.text, let email = emailField.text, let password = passwordField.text {
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                guard let email = authResult?.email, error == nil else {
                    self.set(isLoading: false)
                    self.errorAlert(message: "\(error!.localizedDescription)")
                    return
                }
                let userID = Auth.auth().currentUser?.uid
                FirebaseUtilities.saveUser(ofType: "user", withID: userID!, withName: name, withEmail: email, withPassword: password)
                FirebaseUtilities.saveStats(byUserID: userID!, withTimeInPrayer: 0.0)
                FirebaseUtilities.saveAndResetUserConstants(ofType: "constants", byUserID: userID!, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
                print("\(email) created")
                self.set(isLoading: false)
                LocalFirebaseData.name = name
                self.performSegue(withIdentifier: "signUpSegue", sender: self)
            }
        }
    }
    
    // MARK: - Functions
    

    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
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
