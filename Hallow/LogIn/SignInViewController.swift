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

class SignInViewController: LogInBaseViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var user = User()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
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
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            signIn()
            passwordField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func signInButton(_ sender: Any) {
        signIn()
    }
    
    // MARK: - Function
    
    private func signIn() {
        showLightHud()
        guard let originalEmail = emailField.text, let password = self.passwordField.text else {
            self.dismissHud()
            self.alertWithDismiss(viewController: self, title: "Error", message: "Missing email or password")
            return
        }
        let email = cleanText(text: originalEmail)
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            guard let _ = user?.uid, let userEmail = user?.email, error == nil else {
                self.errorAlert(message: "\(error?.localizedDescription ?? "Error signing in")", viewController: self)
                self.dismissHud()
                return
            }
            FirebaseUtilities.loadUserData(byUserEmail: userEmail) { results in
                guard let results = results.map(User.init).first else {
                    print("FIREBASE: Error loading user data")
                    return
                }
                self.user = results
                guard !self.user.isLoggedIn else {
                    self.errorAlert(message: "User is already signed in on another device", viewController: self)
                    FirebaseUtilities.logOut(viewController: self) {
                        self.dismissHud()
                    }
                    return
                }
                RealmUtilities.signInUser(withUser: self.user) {
                    self.dismissHud()
                    FirebaseUtilities.syncUserData { }
                    self.performSegue(withIdentifier: "signInSegue", sender: self)
                }
            }
            FirebaseUtilities.loadProfilePicture(byUserEmail: self.user.email) { image in
                self.saveImage(image: image)
            } 
        }
    }
}
