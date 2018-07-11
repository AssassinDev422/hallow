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

// TODO - Done button bar on top and next

class RecommendViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameOutlet: UITextField!
    @IBOutlet weak var phoneNumberOutlet: UITextField!
    @IBOutlet weak var emailOutlet: UITextField!
    @IBOutlet weak var submitButtonOutlet: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameOutlet.delegate = self
        nameOutlet.tag = 0
        phoneNumberOutlet.delegate = self
        phoneNumberOutlet.tag = 1
        emailOutlet.delegate = self
        emailOutlet.tag = 2
        
        setUpDoneButton()
        
        navigationItem.title = "Recommend a Friend"

    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    
    // MARK: - Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            submit()
            textField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        submit()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Functions
    
    private func submit () {
        let name = nameOutlet!.text
        let number = phoneNumberOutlet!.text
        let email = emailOutlet!.text
        let submission = "\(String(describing: name)) - \(String(describing: number)) - \(String(describing: email))"
        FirebaseUtilities.sendFeedback(ofType: "recommendation", byUserEmail: self.userEmail!, withEntry: submission)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Design
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
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
        nameOutlet.inputAccessoryView = toolBar
        phoneNumberOutlet.inputAccessoryView = toolBar
        emailOutlet.inputAccessoryView = toolBar

    }
    
    @objc private func doneClicked() {
        view.endEditing(true)
    }
    

}
