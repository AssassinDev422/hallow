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

//TODO: Delay in updating the journal view after clicking update

class JournalEntryViewController: JournalBaseViewController {
    
    @IBOutlet weak var titleField: UILabel!
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var dateField: UILabel!
    
    var journalEntry: JournalEntry?
    var user = User()
    
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
        setUpDoneButton(textView: textField)
    }
    
    // Firebase listener

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error in will appear of journal entry")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of journal entry")
        }
        ReachabilityManager.shared.addListener(listener: self)
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
        guard let entry = textField.text, let docID = journalEntry?.docID, let title = journalEntry?.prayerTitle else {
            print("Error in update")
            return
        }
        FirebaseUtilities.updateReflection(withDocID: docID, byUserEmail: user.email, withEntry: entry, withTitle: title)
        RealmUtilities.updateJournalEntry(withID: docID, withEntry: entry) {
            self.navigationController?.popViewController(animated: true)
            print("ENTRY after popping vc: \(entry)")
        }
    }
    
}
