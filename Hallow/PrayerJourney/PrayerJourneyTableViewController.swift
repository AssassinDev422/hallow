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
    
    var completedPrayers: [PrayerTracking] = []
    
    private let reuseIdentifier = "cell"
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?

    
    var tableViewLoaded: Bool = false
    var row: Int = 0
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let handle = handle else {
            print("Error with handle")
            return
        }
        Auth.auth().removeStateDidChangeListener(handle)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    
    // MARK: - Functions
    
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
        return LocalFirebaseData.prayers.filter {$0.guide == Constants.guide}.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PrayerJourneyTableViewCell
        
        let prayer = LocalFirebaseData.prayers.filter {$0.guide == Constants.guide} [indexPath.row]
        cell.prayerTitleLabel.text = prayer.title
        cell.prayerDescriptionLabel.text = prayer.description
        
        let completed = LocalFirebaseData.completedPrayers.contains {$0 == prayer.title}
        
        let locked = LocalFirebaseData.lockedPrayers.contains {$0 == prayer.title}
        
        if completed == true {
            cell.statusImage.image = #imageLiteral(resourceName: "checkmarkIcon")
            cell.statusImage.tintColor = UIColor(named: "fadedPink")
            cell.statusImage.contentMode = .scaleToFill
            cell.prayerTitleLabel.textColor = UIColor(named: "fadedPink")
            cell.prayerDescriptionLabel.textColor = UIColor(named: "fadedPink")
            cell.playCellButton.isHidden = false
        } else if locked == true {
            cell.statusImage.image = #imageLiteral(resourceName: "passwordIcon")
            cell.playCellButton.isHidden = true
            cell.statusImage.contentMode = .scaleAspectFit
            cell.statusImage.tintColor = UIColor.lightGray
            cell.prayerTitleLabel.textColor = UIColor.lightGray
            cell.prayerDescriptionLabel.textColor = UIColor.lightGray
        } else {
            cell.statusImage.image = UIImage.circle(diameter: 15, color: UIColor(named: "purplishBlue")!)
            cell.statusImage.contentMode = .center
            cell.prayerTitleLabel.textColor = UIColor(named: "darkIndigo")
            cell.prayerDescriptionLabel.textColor = UIColor(named: "darkIndigo")
            cell.playCellButton.isHidden = false
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
        let prayer = LocalFirebaseData.prayers.filter {$0.guide == Constants.guide} [indexPath.item]
        let parent = self.parent as! PrayerJourneySuperViewController
        parent.prayer = prayer
        
        parent.prayerDescriptionLabel.text = prayer.description
        
        let description2 = NSMutableAttributedString(string: prayer.description2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        parent.prayerDescription2Label.attributedText = description2
        
        parent.playSelectedButton.isHidden = false
        parent.prayerTitleLabel.text = prayer.title
        parent.prayerTitleLabel.text?.append(" of 9")
        
        if prayer.title == "Day 9+" {
            parent.playSelectedButton.isHidden = true //FIXME: When I scroll the other day play buttons disappear
            parent.prayerTitleLabel.text = prayer.title
        }
        
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let button:UIButton = sender as! UIButton? {
            let indexPath = button.tag
            let prayer = LocalFirebaseData.prayers.filter {$0.guide == Constants.guide} [indexPath]
            prayNow.prayer = prayer
        }
    }
    
}
