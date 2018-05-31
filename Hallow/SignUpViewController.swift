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

//TODO: What happens if you try to create the same user with an existing email
//TODO: Check what the enter button on the key pad is

class SignUpViewController: UIViewController {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    // MARK: - Life cycle
    
    override func viewDidDisappear(_ animated: Bool) {
        Constants.isFirstDay = true
    }
    
    // MARK: - Actions
    
    @IBAction func signUpButton(_ sender: Any) {
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
                print("\(email) created")
                self.set(isLoading: false)
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
        let hud = JGProgressHUD(style: .dark)
        hud.interactionType = .blockAllTouches
        hud.textLabel.text = "Signing up..."
        return hud
    }()
    
    private func set(isLoading: Bool) {
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: true)
        }
    }
    
}
