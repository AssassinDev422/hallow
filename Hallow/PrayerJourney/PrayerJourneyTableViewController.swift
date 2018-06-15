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
    
    var tableViewLoaded: Bool = false
    var row: Int = 0
    
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
            
            self.checkIfLoaded()
        }
    }
    
    private func loadCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("Completed prayers: \(self.completedPrayers.count)")
            self.tableView!.reloadData()
            
            
        }
    }
    
    func checkIfLoaded() {
        let parent = self.parent as! PrayerJourneySuperViewController
        if self.tableViewLoaded == true {
            if parent.everythingIsLoaded == true {
                updateTableViewPosition()
                print("Everything is loaded in tableview")
                parent.set(isLoading: false)
                parent.hud.dismiss(animated: false)
                
                parent.everythingIsLoaded = false
            } else {
                print("Everything is not loaded in tableview")
                parent.everythingIsLoaded = true
                parent.checkIfLoaded()
            }
            self.tableViewLoaded = false
        } else {
            self.tableViewLoaded = true
            checkIfLoaded()
            print("Everything is not loaded in tableview v2")
        }
    }
    
    private func updateTableViewPosition() {
        let parent = self.parent as! PrayerJourneySuperViewController
        
        if parent.dayNumber == 10 {
            let indexPath = IndexPath(row: 8, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {
            self.row = parent.dayNumber - 1
            let indexPath = IndexPath(row: self.row, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
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
            cell.statusImage.image = #imageLiteral(resourceName: "checkmarkIcon")
            cell.statusImage.contentMode = .scaleToFill
            cell.prayerTitleLabel.textColor = UIColor(named: "fadedPink")
            cell.prayerDescriptionLabel.textColor = UIColor(named: "fadedPink")
        } else {
            cell.statusImage.image = UIImage.circle(diameter: 15, color: UIColor(named: "purplishBlue")!)
            cell.statusImage.contentMode = .center
            cell.prayerTitleLabel.textColor = UIColor(named: "darkIndigo")
            cell.prayerDescriptionLabel.textColor = UIColor(named: "darkIndigo")
        }
        
        cell.layer.borderWidth = 0
        
        cell.playCellButton.tag = indexPath.row
        cell.playCellButton.addTarget(self, action: #selector(PrayerJourneyTableViewController.buttonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        return cell
    }
    
    @objc private func buttonTapped(_ sender: UIButton!){
        self.performSegue(withIdentifier: "tableReturnToPrayNowSegue", sender: sender)
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
        let parent = self.parent as! PrayerJourneySuperViewController
        parent.prayer = prayer
        parent.prayerTitleLabel.text = prayer.title
        parent.prayerTitleLabel.text?.append(" of 9")
        parent.prayerDescriptionLabel.text = prayer.description
        
        let description2 = NSMutableAttributedString(string: prayer.description2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        parent.prayerDescription2Label.attributedText = description2
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let button:UIButton = sender as! UIButton? {
            let indexPath = button.tag
            let prayer = prayers[indexPath]
            prayNow.prayer = prayer
        }
    }
    
}
