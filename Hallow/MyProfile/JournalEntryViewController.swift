//
//  JournalEntryViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/14/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

//TODO: Delay in updating the journal view after clicking update

class JournalEntryViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dateField: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    var journalEntry: JournalEntry?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = journalEntry?.entry
        dateField.text = journalEntry?.date
        
        textField!.layer.borderWidth = 0
        textField!.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        
        textField!.layer.masksToBounds = false
        textField!.layer.shadowColor = UIColor.lightGray.cgColor
        textField!.layer.shadowOpacity = 0.8
        textField!.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        textField!.layer.shadowRadius = 2
        
        navigationItem.title = "Journal Entry"
        
        setUpDoneButton()
        
    }
    
    // Firebase listener

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func updateButton(_ sender: Any) {
        update()
        print("Button is pressed")
    }
    
    private func update() {
        print("journalEntry?.entry: \(journalEntry?.entry ?? "Error")")
        let entry = textField!.text
        let docID = journalEntry?.docID
        FirebaseUtilities.saveReflection(ofType: "journal", byUserID: self.userID!, withEntry: entry!)
        FirebaseUtilities.deleteFile(ofType: "journal", byUser: self.userID!, withID: docID!)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Design
    
    // Add done button to keyboard
    
    private func setUpDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
    }
    
    @objc private func doneClicked() {
        view.endEditing(true)
    }
    
}
