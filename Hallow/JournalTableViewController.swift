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

class JournalTableViewController: UITableViewController {

    var journalEntries: [JournalEntry] = []
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Total journal entries in viewDidLoad: \(self.journalEntries.count)")
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
            self.loadJournalEntries()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Functions
    
    private func loadJournalEntries() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "journal", byUser: self.userID!) { results in
            self.journalEntries = results.map(JournalEntry.init)
            self.journalEntries.sort{$0.dateStored > $1.dateStored}
            print("Journal count in private function: \(self.journalEntries.count)")
            self.tableView!.reloadData()
        }
    }
    
    // MARK: - Tableview data source and set up

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.journalEntries.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! JournalTableViewCell
        let journalEntry = journalEntries[indexPath.row]
        
        cell.dateField.text = journalEntry.date
        cell.entryField.text = journalEntry.entry
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let journalEntry = journalEntries[indexPath.row]
        performSegue(withIdentifier: "journalEntrySegue", sender: journalEntry)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? JournalEntryViewController, let journalEntry = sender as? JournalEntry {
                vc.journalEntry = journalEntry
        }
    }
}
