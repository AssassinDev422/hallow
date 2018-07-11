//
//  PrayerJourneySuperViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class PrayerJourneySuperViewController: UIViewController {

    @IBOutlet weak var prayerTitleLabel: UILabel!
    @IBOutlet weak var prayerDescriptionLabel: UILabel!
    @IBOutlet weak var prayerDescription2Label: UILabel!
    @IBOutlet weak var tableViewContainter: UIView!
    @IBOutlet weak var playSelectedButtonOutlet: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String? 
    
    var prayer: PrayerItem?
    var completedPrayers: [PrayerTracking] = []
    var completedPrayersTitles: [String] = []
    var nextPrayerTitle: String = "Day 1"
    
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
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid  //TODO: Potential bug - with new phone - unexpectedly found nil
            self.userEmail = user?.email
            self.setNextPrayer()
            self.pullUpPrayerData()
        }
        Constants.pausedTime = 0.00
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateTableViewPosition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func playMainPrayerButton(_ sender: Any) {
        performSegue(withIdentifier: "returnToPrayNow", sender: prayer)
    }
    
    // MARK: - Functions
    
    private func setNextPrayer() {
        
        self.completedPrayersTitles = LocalFirebaseData.completedPrayers
        if self.completedPrayersTitles.count > 0 {
            self.completedPrayersTitles.sort()
            self.nextPrayerTitle = self.completedPrayersTitles[self.completedPrayersTitles.count-1]
            self.dayNumber = Int(String(self.nextPrayerTitle.last!))!
            self.dayNumber += 1
            let newDayNumber: String = String(self.dayNumber)
            self.nextPrayerTitle.removeLast()
            self.nextPrayerTitle.append(newDayNumber)
            print(self.nextPrayerTitle)
            if self.dayNumber == 10 {
                LocalFirebaseData.nextPrayerTitle = "Day 9"
            } else {
                LocalFirebaseData.nextPrayerTitle = self.nextPrayerTitle
            }
        } else {
            LocalFirebaseData.nextPrayerTitle = "Day 1"
        }
    }
    
    private func pullUpPrayerData() {
                
        self.prayer = LocalFirebaseData.prayers.filter {$0.title == LocalFirebaseData.nextPrayerTitle}.filter {$0.guide == Constants.guide} [0]
        
        
        self.prayerTitleLabel.text = self.prayer!.title
        self.prayerTitleLabel.text?.append(" of 9")
        self.prayerDescriptionLabel.text = self.prayer!.description

        let description2 = NSMutableAttributedString(string: self.prayer!.description2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        self.prayerDescription2Label.attributedText = description2
        
    }
    
    private func updateTableViewPosition() {
        let child = self.childViewControllers.first as! PrayerJourneyTableViewController

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
