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
    
    var user = User()
    
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
    
    // MARK: - Functions
    
    private func signUp() {
        showLightHud()
        guard let name = nameField.text, let originalEmail = emailField.text, let password = self.passwordField.text else {
            self.dismissHud()
            self.alertWithDismiss(viewController: self, title: "Error", message: "Missing name, email or password")
            return
        }
        let email = cleanText(text: originalEmail)
        
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            guard let email = authResult?.email, error == nil else {
                self.dismissHud()
                self.errorAlert(message: "\(error?.localizedDescription ?? "Error signing up")", viewController: self)
                return
            }
            FirebaseUtilities.createUserData(withEmail: email, withName: name)
            RealmUtilities.createUserData(withEmail: email, withName: name) {
                self.dismissHud()
                self.performSegue(withIdentifier: "signUpSegue", sender: self)
            }
        }
    }
}
