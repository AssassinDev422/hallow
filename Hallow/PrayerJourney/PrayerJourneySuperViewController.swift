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
    
    var prayer: PrayerItem?
    
    var user = User()
    
    var everythingIsLoaded: Bool = false
    
    var dayNumber: Int = 1
    var row: Int = 0
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let realm = try! Realm() //TODO: Change to do catch - not sure if I need this
        guard let realmUser = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        user = realmUser
        self.pullUpPrayerData()

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
    
    // MARK: - Functions
    
    private func pullUpPrayerData() {
        
        let realm = try! Realm() //TODO: Change to do catch - not sure if I need this
        let prayers = realm.objects(PrayerItem.self)

        self.prayer = prayers.filter("title = %@ AND guide = %@ AND length = %@", user.nextPrayerTitle, user.guide, "10 mins") [0]
        
        self.prayerTitleLabel.text = self.prayer!.title
        self.prayerTitleLabel.text?.append(" of 9")
        self.prayerDescriptionLabel.text = self.prayer!.desc

        let description2 = NSMutableAttributedString(string: self.prayer!.desc2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        self.prayerDescription2Label.attributedText = description2
        
    }
    
    private func updateTableViewPosition() {
        let child = self.childViewControllers.first as! PrayerJourneyTableViewController
        
        
        let completes = user.completedPrayers.sorted()
        let nextPrayerTitle = completes[user.completedPrayers.count - 1]
        self.dayNumber = Int(String(nextPrayerTitle.last!))! + 1

        if self.dayNumber == 10 {
            let indexPath = IndexPath(row: 8, section: 0)
            child.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        } else {
            self.row = self.dayNumber - 1
            let indexPath = IndexPath(row: self.row, section: 0)
            child.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            child.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let prayer = sender as? PrayerItem {
            prayNow.prayer = prayer
        }
    }

}
