//
//  JournalEntryViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/14/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

// TODO: Don't love textviews

class JournalEntryViewController: TextBaseViewController {
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var newTitle: UITextField!
    
    var journalEntry: JournalEntry?
    var isNewEntry: Bool = false
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        newTitle.delegate = self
        titleField.text = journalEntry?.prayerTitle
        textField.text = journalEntry?.entry
        dateField.text = journalEntry?.date
        textField!.layer.borderWidth = 0
        textField!.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        navigationItem.title = "Journal Entry"
        setUpTextViewDoneButton(textView: textField)
    }
    
    // Firebase listener

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
        textField.becomeFirstResponder()
        if isNewEntry {
            titleField.isHidden = true
            dateField.isHidden = true
            newTitle.isHidden = false
        } else {
            titleField.isHidden = false
            dateField.isHidden = false
            newTitle.isHidden = true
            titleField.text = journalEntry?.prayerTitle
            textField.text = journalEntry?.entry
            dateField.text = journalEntry?.date
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func updateButtonPressed(_ sender: Any) {
        update()
    }
    
    
    private func update() {
        if isNewEntry {
            guard let entryText = textField.text else {
                print("Error in update is newEntry")
                return
            }
            var prayerTitle = ""
            if let _prayerTitle = newTitle.text {
                prayerTitle = _prayerTitle
            }
            RealmUtilities.saveJournalEntry(entryText: entryText, prayerTitle: prayerTitle) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            guard let user = User.current, let entryText = textField.text, let docID = journalEntry?.docID, let _ = journalEntry?.prayerTitle else {
                print("Error in update") // TODO: When changing to add own journal probs need to update title too
                return
            }
            RealmUtilities.updateJournalEntry(fromUser: user, withID: docID, withEntry: entryText) {
                navigationController?.popViewController(animated: true)
                print("ENTRY after popping vc: \(entryText)")
            }
        }
    }
    
    // MARK: - Design
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        textField.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
    }
    
}
