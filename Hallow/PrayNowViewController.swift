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

class PrayNowViewController: UIViewController {
    
    @IBOutlet weak var prayNowLabel: UIButton!
    @IBOutlet weak var prayerSessionTitle: UILabel!
    @IBOutlet weak var prayerSessionDescription: UILabel!
    @IBOutlet weak var lengthSelectorOutlet: UISegmentedControl!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    var prayer: PrayerItem?
    var completedPrayers: [PrayerTracking] = []
    var completedPrayersTitles: [String] = []
    var nextPrayerTitle: String = "Day 1"
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        set(isLoading: true)
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid  //TODO: Potential bug - with new phone - unexpectedly found nil
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
    
    
    // MARK: - Actions
    
    @IBAction func lengthChanged(_ sender: Any) {
        self.hud.show(in: view, animated: false)
        let prayerLength = self.lengthSelectorOutlet.titleForSegment(at: self.lengthSelectorOutlet.selectedSegmentIndex)!
        self.loadPrayerSession(withTitle: self.nextPrayerTitle, withLength: prayerLength)
        print("Prayer length changed: \(prayerLength)")
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
                var dayNumber: Int = Int(String(self.nextPrayerTitle.last!))!
                dayNumber += 1
                let newDayNumber: String = String(dayNumber)
                self.nextPrayerTitle.removeLast()
                self.nextPrayerTitle.append(newDayNumber)  
                print(self.nextPrayerTitle)
                self.loadPrayerSession(withTitle: self.nextPrayerTitle, withLength: "10 mins")
                print("Loading prayer session: \(self.nextPrayerTitle)")
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
            print("Prayer title \(self.prayer!.title)")
            print("Prayer length \(self.prayer!.length)")
            self.prayerSessionTitle.text = self.prayer!.title
            self.prayerSessionDescription.text = self.prayer!.description
            self.set(isLoading: false)
            self.hud.dismiss(animated: true)
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
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: true)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let AudioPlayerViewController = destinationViewController as? AudioPlayerViewController,
            let _ = segue.identifier {
                let prayer = self.prayer
                print("Prayer length selected: \(prayer!.length)")
                AudioPlayerViewController.prayer = prayer
                print("Prayer title in prepare for segue: \(prayer!.title)")  //TODO: Potential bug - Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
        }
    }
}
