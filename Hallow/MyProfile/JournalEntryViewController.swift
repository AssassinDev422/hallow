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

class JournalEntryViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dateField: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
    
    var frame: CGRect?

    var journalEntry: JournalEntry?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        titleField.text = journalEntry?.prayerTitle
        textField.text = journalEntry?.entry
        dateField.text = journalEntry?.date
        
        textField!.layer.borderWidth = 0
        textField!.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        
        navigationItem.title = "Journal Entry"
        
        setUpDoneButton()
        
    }
    
    // Firebase listener

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Actions
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        print("tap gesture")
    }
    
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        print("update button pressed")
        update()
    }
    
    
    private func update() {
        print("journalEntry?.entry: \(journalEntry?.entry ?? "Error")")
        let entry = textField!.text
        let docID = journalEntry?.docID
        FirebaseUtilities.saveReflection(ofType: "journal", byUserEmail: self.userEmail!, withEntry: entry!, withTitle: journalEntry!.prayerTitle)
        FirebaseUtilities.deleteFile(ofType: "journal", byUserEmail: self.userEmail!, withID: docID!)
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
    
    // MARK: - Design
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Did begin editing")
        self.frame = textView.frame
        var newFrame = self.frame!
        newFrame.size.height = self.frame!.height / 2.5
        textView.frame = newFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.frame = self.frame!
    }
    
}
