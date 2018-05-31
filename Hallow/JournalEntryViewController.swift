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
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    var journalEntry: JournalEntry?
    
    let segmentTitles = ["Hardly", "Barely", "Fairly", "Very"]
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = journalEntry?.entry
        
        textField!.layer.borderWidth = 1
        textField!.layer.borderColor = UIColor.black.cgColor
        
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
    
    @IBAction func updateButton(_ sender: Any) {
        print("journalEntry?.entry: \(journalEntry?.entry ?? "Error")")
        let entry = textField!.text
        let docID = journalEntry?.docID
        FirebaseUtilities.saveReflection(ofType: "journal", byUserID: self.userID!, withEntry: entry!)
        FirebaseUtilities.deleteFile(ofType: "journal", byUser: self.userID!, withID: docID!)
        self.navigationController?.popViewController(animated: true)
    }
}
