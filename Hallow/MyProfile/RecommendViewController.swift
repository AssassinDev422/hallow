//
//  RecommendViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/26/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import RealmSwift

// TODO - Done button bar on top and next

class RecommendViewController: LogInBaseViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    
    var user = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        phoneNumberField.delegate = self
        emailField.delegate = self
        
        setUpDoneButton(textField: nameField)
        setUpDoneButton(textField: phoneNumberField)
        setUpDoneButton(textField: emailField)
        
        navigationItem.title = "Recommend a Friend"

    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm() //TODO: Change to do catch
        guard let realmUser = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        user = realmUser
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    
    // MARK: - Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameField {
            phoneNumberField.becomeFirstResponder()
        } else if textField == phoneNumberField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            submit()
            emailField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        submit()
    }
    
    // MARK: - Functions
    
    private func submit () {
        let name = nameField!.text
        let number = phoneNumberField!.text
        let email = emailField!.text
        let submission = "\(String(describing: name)) - \(String(describing: number)) - \(String(describing: email))"
        FirebaseUtilities.sendFeedback(ofType: "recommendation", byUserEmail: user.email, withEntry: submission)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Design
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        textField.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
    }

}
