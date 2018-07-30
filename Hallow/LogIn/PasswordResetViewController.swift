//
//  PasswordResetViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class PasswordResetViewController: LogInBaseViewController {
    
    @IBOutlet weak var emailField: UITextField!
        
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        setUpDoneButton(textField: emailField)
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
        textField.resignFirstResponder()
        sendReset()
        return false
    }
    
    @IBAction func sendResetEmail(_ sender: Any) {
        sendReset()
    }
    
    @IBAction func backToLogIn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Functions
    
    private func sendReset() {
        showLightHud()
        guard let originalEmail = emailField.text else {
            self.dismissHud()
            self.alertWithDismiss(viewController: self, title: "Error", message: "No email entered into email field")
            return
        }
        let email = cleanText(text: originalEmail)
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                self.dismissHud()
                self.errorAlert(message: "\(error.localizedDescription)", viewController: self)
            } else {
                self.dismissHud()
                self.alertWithDismiss(viewController: self, title: "Thanks!", message: "Check your email for next steps")
            }
        }
    }
}
