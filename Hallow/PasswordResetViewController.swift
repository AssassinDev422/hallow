//
//  PasswordResetViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

class PasswordResetViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    
    // MARK: - Actions
    
    @IBAction func sendResetEmail(_ sender: Any) {
        if let email = self.emailField.text {
            Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error {
                    self.errorAlert(message: "\(error.localizedDescription)")
                }
            }
            self.resetAlert()
        }
    }
    
    // MARK: - Functions
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    private func resetAlert() {
        let alert = UIAlertController(title: "Thanks!", message: "Check your email for next steps", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "afterPasswordResetSegue", sender: nil)
        }))
        self.present(alert, animated: true)
    }
}
