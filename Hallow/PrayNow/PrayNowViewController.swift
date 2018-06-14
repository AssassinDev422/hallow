//
//  PrayNowViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import JGProgressHUD
import Firebase

// TODO: Remove multiple downloaded files after playing

// FIXME: PrayerSuper desc

// FIXME: appearance in iPhone 5s (test with clicking back and forth in iPhone 8)

class PrayNowViewController: UIViewController {
    
    @IBOutlet weak var prayNowLabel: UIButton!
    @IBOutlet weak var prayerSessionTitle: UILabel!
    @IBOutlet weak var prayerSessionDescription: UILabel!
    @IBOutlet weak var prayerSessionDescription2: UILabel!
    @IBOutlet weak var lengthSelectorOutlet: UISegmentedControl!
    @IBOutlet weak var selectorBar: UIView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    var prayer: PrayerItem?
    var completedPrayers: [PrayerTracking] = []
    var completedPrayersTitles: [String] = []
    var nextPrayerTitle: String = "Day 1"
    var lengthWasChanged: Bool = false
    var prayerLength: String = "10 mins"
    
    var prayer10mins: PrayerItem?
    var prayer5mins: PrayerItem?
    var prayer15mins: PrayerItem?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSelector()
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.set(isLoading: true)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid 
            if let prayer = self.prayer {
                self.loadPrayerSession(withTitle: prayer.title, withLength: "10 mins")
                print("Loading later prayer session")
                print("prayerTitle: \(prayer.title)")
            } else {
                self.setNextPrayerAndLoad()
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setSelectorBarPosition()
    }
    
    // MARK: - Actions
    
    @IBAction func lengthChanged(_ sender: Any) {
        self.prayerLength = self.lengthSelectorOutlet.titleForSegment(at: self.lengthSelectorOutlet.selectedSegmentIndex)!
        if self.prayerLength == "5 mins" {
            self.prayer = self.prayer5mins
        } else if self.prayerLength == "15 mins" {
            self.prayer = self.prayer15mins
        } else {
            self.prayer = self.prayer10mins
        }
        print("Prayer length changed: \(prayerLength)")

        UIView.animate(withDuration: 0.3) {
            self.setSelectorBarPosition()
        }
    }

    @IBAction func prayNowReleased(_ sender: Any) {
        prayNowLabel.backgroundColor = UIColor(named: "purplishBlue")
    }
    
    
    @IBAction func prayNowPressed(_ sender: Any) {
        prayNowLabel.backgroundColor = UIColor(named: "darkIndigo")
    }
    
    // MARK: - Functions
    
    private func setNextPrayerAndLoad() {
        if self.userID != nil {
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
                    var dayNumber: Int = Int(String(self.nextPrayerTitle.last!))!
                    dayNumber += 1
                    let newDayNumber: String = String(dayNumber)
                    self.nextPrayerTitle.removeLast()
                    self.nextPrayerTitle.append(newDayNumber)
                    print(self.nextPrayerTitle)
                    if dayNumber == 10 {
                        print("dayNumber was equal to 10 and we are performing segue")
                        self.performSegue(withIdentifier: "completedSegue", sender: self)
                    } else {
                        self.loadPrayerSession(withTitle: self.nextPrayerTitle, withLength: "10 mins")
                        print("Loading prayer session: \(self.nextPrayerTitle)")
                    }
                } else {
                    print("Kept next prayer set as Day 1 since there are no completed prayers")
                    self.loadPrayerSession(withTitle: self.nextPrayerTitle, withLength: "10 mins")
                }
            }
        } else {
            print("Do not have user ID ***************")
            self.loadPrayerSession(withTitle: "Day 1", withLength: "10 mins")
        }
    }
    
    private func loadPrayerSession(withTitle title: String, withLength length: String) {
        FirebaseUtilities.loadSpecificDocumentByGuideAndLength(ofType: "prayer", withTitle: title, byGuide: Constants.guide, withLength: length) { result in
            self.prayer10mins = PrayerItem(firestoreDocument: result[0]) //TODO: Potential bug - Abby's Day 1 gets messed up
            self.prayer = self.prayer10mins
            self.prayerSessionTitle.text = self.prayer!.title
            self.prayerSessionTitle.text?.append(" of 9")
            self.prayerSessionDescription.text = self.prayer!.description
            
            let description2 = NSMutableAttributedString(string: self.prayer!.description2)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 10
            description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
            self.prayerSessionDescription2.attributedText = description2

            FirebaseUtilities.loadSpecificDocumentByGuideAndLength(ofType: "prayer", withTitle: title, byGuide: Constants.guide, withLength: "5 mins") { result in
                self.prayer5mins = PrayerItem(firestoreDocument: result[0]) //TODO: Potential bug - Abby's Day 1 gets messed up
            }
            FirebaseUtilities.loadSpecificDocumentByGuideAndLength(ofType: "prayer", withTitle: title, byGuide: Constants.guide, withLength: "15 mins") { result in
                self.prayer15mins = PrayerItem(firestoreDocument: result[0]) //TODO: Potential bug - Abby's Day 1 gets messed up
            }
            
            self.set(isLoading: false)
            self.hud.dismiss(animated: false)
        }
    }
    
    private func setSelectorBarPosition() {
        let width = self.lengthSelectorOutlet.frame.width / 3
        let origin = self.lengthSelectorOutlet.frame.origin.x
        let index = self.lengthSelectorOutlet.selectedSegmentIndex
        if index == 0 {
            self.selectorBar.frame.origin.x = origin
        } else if index == 1 {
            self.selectorBar.frame.origin.x = origin + width
        } else {
            self.selectorBar.frame.origin.x = origin + 2 * width
        }
    }
    
    // Sets up hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .extraLight)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    private func set(isLoading: Bool) {
        self.prayerSessionTitle.isHidden = isLoading
        self.prayerSessionDescription.isHidden = isLoading
        self.prayNowLabel.isHidden = isLoading
        self.lengthSelectorOutlet.isHidden = isLoading
        self.selectorBar.isHidden = isLoading
        self.prayerSessionDescription2.isHidden = isLoading
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: false)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let AudioPlayerViewController = destinationViewController as? AudioPlayerViewController,
            let _ = segue.identifier {
                self.prayer?.length = self.prayerLength
                let prayer = self.prayer
                print("Prayer length selected: \(prayer!.length)")
                AudioPlayerViewController.prayer = prayer
                print("Prayer title in prepare for segue: \(prayer!.title)")  //TODO: Potential bug - Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
            }
    }
    
    // MARK: - Design
    
    private func setUpSelector() {
        
        lengthSelectorOutlet.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Montserrat-Black", size: 18) as Any,
            NSAttributedStringKey.foregroundColor: UIColor(named: "darkIndigo") as Any
            ], for: .normal)
        
        lengthSelectorOutlet.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Montserrat-Black", size: 18) as Any,
            NSAttributedStringKey.foregroundColor: UIColor(named: "fadedPink") as Any
            ], for: .selected)
        
    }
    
    
    
}
