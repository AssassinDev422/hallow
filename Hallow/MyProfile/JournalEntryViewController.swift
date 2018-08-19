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
    @IBOutlet weak var dateField: UILabel!
    @IBOutlet weak var textField: UITextView!
    
    var journalEntry: JournalEntry?
    var isNewEntry: Bool = false
    
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
        } else {
            titleField.isHidden = false
            dateField.isHidden = false
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
            let prayerTitle = "Ad hoc entry"
            RealmUtilities.saveJournalEntry(entryText: entryText, prayerTitle: prayerTitle) {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            guard let user = User.current, let entryText = textField.text, let docID = journalEntry?.docID, let _ = journalEntry?.prayerTitle else {
                print("Error in update")
                return
            }
            RealmUtilities.updateJournalEntry(fromUser: user, withID: docID, withEntry: entryText) {
                navigationController?.popViewController(animated: true)
                print("ENTRY after popping vc: \(entryText)")
            }
        }
    }
        
}
