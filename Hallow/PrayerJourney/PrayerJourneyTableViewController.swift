//
//  PrayerJourneyTableViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class PrayerJourneyTableViewController: UITableViewController {
    
    private let reuseIdentifier = "cell"
    var tableViewLoaded: Bool = false
    var chapterIndex: Int = 0
    var prayers: [Prayer] = []
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    
    // MARK: - Functions
    
    private func updateTableViewPosition() {
        guard let parent = parent as? PrayerJourneySuperViewController else {
            print("Error in updateTableViewPosition")
            return
        }
        if parent.nextPrayerIndex == 10 {
            let indexPath = IndexPath(row: 8, section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {
            let indexPath = IndexPath(row: (parent.nextPrayerIndex - 1), section: 0)
            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            let realm = try Realm()
            guard let user = User.current else {
                print("ERROR in pulling user data - it's nil")
                return 0
            }
            prayers = Array(realm.objects(Prayer.self).filter("chapterIndex = %@ AND guide = %@ AND length = %@", chapterIndex, user._guide, "10 mins"))
            return prayers.count
        } catch {
            print("REALM: Error in prayer journey table view - tableview number of rows")
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PrayerJourneyTableViewCell
        let prayer = prayers[indexPath.row]
        cell.prayerTitleLabel.text = prayer.title
        cell.prayerDescriptionLabel.text = prayer.desc3
        guard let user = User.current else {
            print("ERROR in pulling user data - it's nil")
            return cell
        }
        let completed = user.completedPrayers.contains {$0 == "\(prayer.prayerIndex)"}
        if completed {
            cell.statusImage.image = #imageLiteral(resourceName: "checkmarkIcon")
            cell.statusImage.tintColor = UIColor(named: "fadedPink")
            cell.statusImage.contentMode = .scaleToFill
            cell.prayerTitleLabel.textColor = UIColor(named: "fadedPink")
            cell.prayerDescriptionLabel.textColor = UIColor(named: "fadedPink")
            cell.playCellButton.isHidden = false
        } else {
            guard let purplishBlue = UIColor(named: "purplishBlue") else {
                print("Error in cellForRowAt")
                return cell
            }
            cell.statusImage.image = UIImage.circle(diameter: 15, color: purplishBlue)
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
        performSegue(withIdentifier: "tableReturnToPrayNowSegue", sender: sender)
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
        guard let parent = parent as? PrayerJourneySuperViewController else {
            print("Error in didSelectRowAt")
            return
        }
        let prayer = prayers[indexPath.item]
        parent.prayer = prayer
        parent.prayerDescriptionLabel.text = prayer.desc
        let description2 = NSMutableAttributedString(string: prayer.desc2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        parent.prayerDescription2Label.attributedText = description2
        parent.playSelectedButton.isHidden = false
        parent.prayerTitleLabel.text = prayer.title
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let button:UIButton = sender as! UIButton? {
            let indexPath = button.tag
            let prayer = prayers[indexPath]
            prayNow.prayer = prayer
        }
    }
    
}
