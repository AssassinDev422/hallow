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
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            if let prayer = self.prayer {
                self.setPrayerSessionWithoutLoading()
                
                if prayer.title == "Day 9" {
                    Constants.hasCompleted = true
                } else {
                    Constants.hasCompleted = false
                }
                
                print("prayerTitle in Pray Now will appear: \(prayer.title)")
                
            } else {
                self.set(isLoading: true)
                self.setNextPrayerAndLoad()
                
                if Constants.isFirstDay == true {
                    self.tabBarController?.tabBar.isHidden = true
                }
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
    
    // MARK: - Functions
    
    private func setNextPrayerAndLoad() {
        if self.userID != nil {
            FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUser: self.userID!) {results in
                self.completedPrayers = results.map(PrayerTracking.init)
                print("Completed prayers: \(self.completedPrayers.count)")
                if self.completedPrayers.count > 0 {
                    for completedPrayer in self.completedPrayers {
                        self.completedPrayersTitles.append(completedPrayer.title)
                        LocalFirebaseData.completedPrayers.append(completedPrayer.title)
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
                        Constants.hasCompleted = true
                        print("HAS COMPLETED: \(Constants.hasCompleted)")
                        self.setPrayerSession(withTitle: "Day 9")
                        LocalFirebaseData.nextPrayerTitle = "Day 9"
                    } else {
                        self.setPrayerSession(withTitle: self.nextPrayerTitle)
                        if self.nextPrayerTitle == "Day 9" {
                            Constants.hasCompleted = true
                        } else {
                            Constants.hasCompleted = false
                        }
                        LocalFirebaseData.nextPrayerTitle = self.nextPrayerTitle
                        print("Loading prayer session: \(self.nextPrayerTitle)")
                    }
                } else {
                    Constants.hasCompleted = false
                    print("Kept next prayer set as Day 1 since there are no completed prayers")
                    self.setPrayerSession(withTitle: self.nextPrayerTitle)
                    LocalFirebaseData.nextPrayerTitle = "Day 1"
                }
            }
        } else {
            print("Do not have user ID ***************")
            self.setPrayerSession(withTitle: "Day 1")
            LocalFirebaseData.nextPrayerTitle = "Day 1" 
        }
    }
    
    private func setPrayerSession(withTitle title: String) {
        
        self.prayer5mins = LocalFirebaseData.prayers5mins.filter {$0.title == title}.filter {$0.guide == Constants.guide} [0]
        
        print("IN NEW SET METHOD 5 MINS - PRAYER TITLE: \(String(describing: self.prayer5mins?.title))")
        print("IN NEW SET METHOD 5 MINS - PRAYER GUIDE: \(String(describing: self.prayer5mins?.guide))")
        print("IN NEW SET METHOD 5 MINS - PRAYER LENGTH: \(String(describing: self.prayer5mins?.length))")

        self.prayer10mins = LocalFirebaseData.prayers10mins.filter {$0.title == title}.filter {$0.guide == Constants.guide} [0]
        self.prayer15mins = LocalFirebaseData.prayers15mins.filter {$0.title == title}.filter {$0.guide == Constants.guide} [0]
                
        self.prayer = self.prayer10mins
        
        
        self.prayerSessionTitle.text = self.prayer!.title
        self.prayerSessionTitle.text?.append(" of 9")
        self.prayerSessionDescription.text = self.prayer!.description
        
        let description2 = NSMutableAttributedString(string: self.prayer!.description2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        self.prayerSessionDescription2.attributedText = description2
        
        self.set(isLoading: false)
    }
    
    private func setPrayerSessionWithoutLoading() {
        
        self.prayer5mins = LocalFirebaseData.prayers5mins.filter {$0.title == prayer!.title}.filter {$0.guide == Constants.guide} [0]
        
        print("IN NO LOADING SET METHOD 5 MINS - PRAYER TITLE: \(String(describing: self.prayer5mins?.title))")
        print("IN NO LOADING SET METHOD 5 MINS - PRAYER GUIDE: \(String(describing: self.prayer5mins?.guide))")
        print("IN NO LOADING SET METHOD 5 MINS - PRAYER LENGTH: \(String(describing: self.prayer5mins?.length))")
        
        self.prayer10mins = LocalFirebaseData.prayers10mins.filter {$0.title == prayer!.title}.filter {$0.guide == Constants.guide} [0]
        self.prayer15mins = LocalFirebaseData.prayers15mins.filter {$0.title == prayer!.title}.filter {$0.guide == Constants.guide} [0]
        
        self.prayer = self.prayer10mins
        
        self.prayerSessionTitle.text = self.prayer!.title
        self.prayerSessionTitle.text?.append(" of 9")
        self.prayerSessionDescription.text = self.prayer!.description
        
        let description2 = NSMutableAttributedString(string: self.prayer!.description2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        self.prayerSessionDescription2.attributedText = description2
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
                print("PRAYER GUIDE IN SEGUE: \(prayer!.guide)")
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
