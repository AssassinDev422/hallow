//
//  PrayerJourneyTableViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

class PrayerJourneyTableViewController: UITableViewController {
    
    var prayers: [PrayerItem] = []
    var completedPrayers: [PrayerTracking] = []
    
    private let reuseIdentifier = "cell"
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAllPrayers()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
            self.loadCompletedPrayers()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    
    // MARK: - Functions
    
    private func loadAllPrayers() {
        FirebaseUtilities.loadAllDocumentsByGuideStandardLength(ofType: "prayer", byGuide: Constants.guide) { results in
            self.prayers = results.map(PrayerItem.init)
            self.prayers.sort{$0.title < $1.title}
            print("Prayer guide: \(Constants.guide)")
            print("Prayer sessions: \(self.prayers.count)")
            self.tableView!.reloadData()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("Completed prayers: \(self.completedPrayers.count)")
            self.tableView!.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Prayer sessions: \(prayers.count)")
        return prayers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PrayerJourneyTableViewCell
        
        let prayer = prayers[indexPath.row]
        cell.prayerTitleLabel.text = prayer.title
        cell.prayerDescriptionLabel.text = prayer.description
        
        let completed = self.completedPrayers.contains {$0.title == prayer.title}
        if completed == true {
            cell.layer.backgroundColor = UIColor.lightGray.cgColor
            cell.layer.borderColor = UIColor.darkGray.cgColor
            cell.prayerTitleLabel.textColor = UIColor.darkGray
            cell.prayerDescriptionLabel.textColor = UIColor.darkGray
        } else {
            cell.layer.backgroundColor = UIColor.clear.cgColor
            cell.layer.borderColor = UIColor.black.cgColor
            cell.prayerTitleLabel.textColor = UIColor.black
            cell.prayerDescriptionLabel.textColor = UIColor.black
        }
        
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    // MARK: - Table view delegate and appearance
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.backgroundColor = UIColor.clear

    }
    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let prayer = prayers[indexPath.item]
//        performSegue(withIdentifier: "tableReturnToPrayNowSegue", sender: prayer)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let prayer = sender as? PrayerItem {
            prayNow.prayer = prayer
        }
    }
    
}
