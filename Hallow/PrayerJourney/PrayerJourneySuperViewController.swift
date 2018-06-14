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
        self.set(isLoading: true)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid  //TODO: Potential bug - with new phone - unexpectedly found nil
                self.setNextPrayerAndLoad()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Actions
    
    @IBAction func playMainPrayerButton(_ sender: Any) {
        performSegue(withIdentifier: "returnToPrayNow", sender: prayer)
    }
    
    // MARK: - Functions
    
    private func setNextPrayerAndLoad() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            print("Completed prayers: \(self.completedPrayers.count)")
            if self.completedPrayers.count > 0 {
                for completedPrayer in self.completedPrayers {
                    self.completedPrayersTitles.append(completedPrayer.title)
                }
                self.completedPrayersTitles.sort()
                print("Completed prayers in array: \(self.completedPrayersTitles)")
                self.nextPrayerTitle = self.completedPrayersTitles[self.completedPrayersTitles.count-1]
                self.dayNumber = Int(String(self.nextPrayerTitle.last!))!
                self.dayNumber += 1
                let newDayNumber: String = String(self.dayNumber)
                self.nextPrayerTitle.removeLast()
                self.nextPrayerTitle.append(newDayNumber)
                print(self.nextPrayerTitle)
                if self.dayNumber == 10 {
                    self.loadPrayerSession(withTitle: "Day 9", withLength: "10 mins")
                } else {
                    self.loadPrayerSession(withTitle: self.nextPrayerTitle, withLength: "10 mins")
                    print("Loading prayer session: \(self.nextPrayerTitle)")
                }
            } else {
                print("Kept next prayer set as Day 1 since there are no completed prayers")
                self.loadPrayerSession(withTitle: self.nextPrayerTitle, withLength: "10 mins")
            }
        }
    }
    
    private func loadPrayerSession(withTitle title: String, withLength length: String) {
        self.set(isLoading: true)
        FirebaseUtilities.loadSpecificDocumentByGuideAndLength(ofType: "prayer", withTitle: title, byGuide: Constants.guide, withLength: length) { result in
            self.prayer = PrayerItem(firestoreDocument: result[0]) //TODO: Potential bug - Abby's Day 1 gets messed up
            self.prayerTitleLabel.text = self.prayer!.title
            self.prayerTitleLabel.text?.append(" of 9")
            self.prayerDescriptionLabel.text = self.prayer!.description
            
            let description2 = NSMutableAttributedString(string: self.prayer!.description2)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
            self.prayerDescription2Label.attributedText = description2
            
            self.checkIfLoaded()
        }
    }
    
    
    func checkIfLoaded() {
        let child = self.childViewControllers.first as! PrayerJourneyTableViewController

        if self.everythingIsLoaded == true {
            updateTableViewPosition()
            
            self.set(isLoading: false)
            self.hud.dismiss(animated: false)
            
            print("Everything is loaded in superview")
            
            self.everythingIsLoaded = false
        } else {
            print("Everything is not loaded in superview")
            self.everythingIsLoaded = true
            child.checkIfLoaded()
        }
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
        }
    }
    
    // Sets up hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .extraLight)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    func set(isLoading: Bool) {
        self.prayerTitleLabel.isHidden = isLoading
        self.prayerDescriptionLabel.isHidden = isLoading
        self.prayerDescription2Label.isHidden = isLoading
        self.tableViewContainter.isHidden = isLoading
        self.playSelectedButtonOutlet.isHidden = isLoading
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: false)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let prayer = sender as? PrayerItem {
            prayNow.prayer = prayer
        }
    }

}
