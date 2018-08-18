//
//  JournalViewTableTableViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/22/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase
import JGProgressHUD
import RealmSwift

class JournalTableViewController: BaseTableViewController {

    var journalEntries: [JournalEntry] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "fadedPink")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            guard let user = User.current else {
                print("ERROR in pulling user data - it's nil")
                return
            }
            journalEntries = Array(realm.objects(JournalEntry.self).filter("userEmail = %a", user.email).sorted(byKeyPath: "dateStored", ascending: false))
        } catch {
            print("REALM: Error in will appear of journal table view")
        }
        tableView.reloadData()
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // Sets up hud
    
    func set(isLoading: Bool) {
        tableView.isHidden = isLoading
        if isLoading {
            showLightHud()
        } else {
            dismissHud()
        }
    }
    
    // MARK: - Tableview data source and set up

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journalEntries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JournalTableViewCell
        let journalEntry = journalEntries[indexPath.row]
        cell.titleField.text = journalEntry.prayerTitle
        cell.dateField.text = journalEntry.date
        cell.entryField.text = journalEntry.entry
        return cell
    }
    
    // Delete rows
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete), let user = User.current {
            let entry = journalEntries[indexPath.row]
            let docID = entry.docID
            RealmUtilities.deleteJournalEntry(fromUser: user, withID: docID) {
                journalEntries.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
            }
        }
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let journalEntry = journalEntries[indexPath.row]
        performSegue(withIdentifier: "journalEntrySegue", sender: journalEntry)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? JournalEntryViewController, let journalEntry = sender as? JournalEntry,  segue.identifier == "journalEntrySegue" {
                vc.journalEntry = journalEntry
                vc.isNewEntry = false
        } else if let vc = segue.destination as? JournalEntryViewController, segue.identifier == "newEntrySegue" {
            vc.isNewEntry = true
            print("In new entry segue")
        }
    }
}
