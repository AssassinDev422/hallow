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

class RecommendViewController: TextBaseViewController {
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.delegate = self
        phoneNumberField.delegate = self
        emailField.delegate = self
        setUpTextFieldDoneButton(textField: nameField)
        setUpTextFieldDoneButton(textField: phoneNumberField)
        setUpTextFieldDoneButton(textField: emailField)
        navigationItem.title = "Recommend a Friend"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleField.text = "Let us know their info and we'll reach out!"
        hideToggle(isHidden: false)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    
    // MARK: - Actions
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === nameField {
            phoneNumberField.becomeFirstResponder()
        } else if textField === phoneNumberField {
            emailField.becomeFirstResponder()
        } else if textField === emailField {
            submit()
            emailField.resignFirstResponder()
        }
        return false
    }
    
    @IBAction func submitButtonPressed(_ sender: Any) {
        submit()
    }
    
    // MARK: - Functions
    
    private func submit() {
        guard let user = User.current, let name = nameField.text, let number = phoneNumberField.text, let email = emailField.text else {
            print("Error in submit")
            return
        }
        let submission = "\(String(describing: name)) - \(String(describing: number)) - \(String(describing: email))"
        FirebaseUtilities.saveOtherData(ofType: "Recommendation", byUserEmail: user.email, withEntry: submission)
        titleField.text = "Successfully submitted - thanks!"
        hideToggle(isHidden: true)
    }
    
    private func hideToggle(isHidden: Bool) {
        nameField.isHidden = isHidden
        emailField.isHidden = isHidden
        phoneNumberField.isHidden = isHidden
        submitButton.isHidden = isHidden
    }
    
    // MARK: - Design
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        textField.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
    }
}
