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
    var user = User()
    var tableViewLoaded: Bool = false
    var row: Int = 0
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error in will appear of prayer journey table view")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of prayer journey table view")
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    
    // MARK: - Functions
    
    private func updateTableViewPosition() {
        guard let parent = self.parent as? PrayerJourneySuperViewController else {
            print("Error in updateTableViewPosition")
            return
        }
        if parent.dayNumber == 10 {
            let indexPath = IndexPath(row: 8, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {
            print("DAY NUMBER: \(parent.dayNumber)")
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
        do {
            let realm = try Realm() //TODO: Change to do catch - not sure if I need this
            return realm.objects(PrayerItem.self).filter("guide = %@ AND length = %@", user._guide, "10 mins").count
        } catch {
            print("REALM: Error in prayer journey table view - tableview number of rows")
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PrayerJourneyTableViewCell
        do {
            let realm = try Realm()
            let prayer = realm.objects(PrayerItem.self).filter("guide = %@ AND length = %@", user._guide, "10 mins") [indexPath.row]
            cell.prayerTitleLabel.text = prayer.title
            cell.prayerDescriptionLabel.text = prayer.desc
            let completed = user.completedPrayers.contains {$0 == prayer.title}
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
        } catch {
            print("REALM: Error in prayer journey table view - tableview cell for row at")
        }
        
        // TODO: - have to delete prayer 9+
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
        do {
            let realm = try Realm()
            let prayer = realm.objects(PrayerItem.self).filter("guide = %@ AND length = %@", user._guide, "10 mins") [indexPath.item]
            guard let parent = self.parent as? PrayerJourneySuperViewController else {
                print("Error in didSelectRowAt")
                return
            }
            parent.prayer = prayer
            parent.prayerDescriptionLabel.text = prayer.desc
            let description2 = NSMutableAttributedString(string: prayer.desc2)
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
        } catch {
            print("REALM: Error in prayer journey table view - did select row at")
        }
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let button:UIButton = sender as! UIButton? {
            let indexPath = button.tag
            do {
                let realm = try Realm()
                let prayer = realm.objects(PrayerItem.self).filter("guide = %@ AND length = %@", user._guide, "10 mins") [indexPath]
                prayNow.prayer = prayer
            } catch {
                print("REALM: Error in prayer journey table view - prepare for segue")
            }
        }
    }
    
}
