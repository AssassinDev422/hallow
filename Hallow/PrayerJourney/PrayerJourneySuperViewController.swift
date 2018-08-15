//
//  PrayerJourneySuperViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import RealmSwift

class PrayerJourneySuperViewController: UIViewController {

    @IBOutlet weak var prayerTitleLabel: UILabel!
    @IBOutlet weak var prayerDescriptionLabel: UILabel!
    @IBOutlet weak var prayerDescription2Label: UILabel!
    @IBOutlet weak var tableViewContainter: UIView!
    @IBOutlet weak var playSelectedButton: UIButton!
    
    var prayer: Prayer?
    var user = User()
    var everythingIsLoaded: Bool = false
    var nextPrayerIndex: Int = 1
    var chapterIndex: Int = 0
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isTranslucent = false
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error in will appear of prayer journey")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of prayer journey")
        }
        pullUpPrayerData()
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableViewPosition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func playMainPrayerButton(_ sender: Any) {
        performSegue(withIdentifier: "returnToPrayNow", sender: prayer)
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Functions
    
    private func pullUpPrayerData() {
        do {
            let realm = try Realm() 
            let prayers = realm.objects(Prayer.self)
            prayer = prayers.filter("chapterIndex = %@ AND prayerIndex = %@ AND guide = %@ AND length = %@", chapterIndex, user.nextPrayerIndex, user._guide, "10 mins").first
        } catch {
            print("REALM: Error in prayer journey - pullUpPrayerData")
        }
        
        guard let prayer = prayer else {
            print("Error in pullUpPrayerData")
            return
        }
        let child = childViewControllers.first as! PrayerJourneyTableViewController
        child.chapterIndex = chapterIndex
        
        prayerTitleLabel.text = prayer.title
        prayerDescriptionLabel.text = prayer.desc

        let description2 = NSMutableAttributedString(string: prayer.desc2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        prayerDescription2Label.attributedText = description2
    }
    
    private func updateTableViewPosition() {
        let lastCompleted = user.completedPrayers.sorted()[user.completedPrayers.count - 1]
        let child = childViewControllers.first as! PrayerJourneyTableViewController
        guard let _nextPrayerIndex = Int(String(lastCompleted)) else {
            print("Error in updateTableViewPosition Int()")
            return
        }
        self.nextPrayerIndex = _nextPrayerIndex + 1
        if self.nextPrayerIndex == 10 {
            let indexPath = IndexPath(row: 8, section: 0)
            child.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {
            let indexPath = IndexPath(row: (self.nextPrayerIndex - 1), section: 0)
            child.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            child.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let prayer = sender as? Prayer {
            prayNow.prayer = prayer
        }
    }
}
