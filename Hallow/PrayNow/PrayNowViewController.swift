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
import RealmSwift

// TODO: Remove multiple downloaded files after playing

class PrayNowViewController: BaseViewController {
    
    @IBOutlet weak var prayNowLabel: UIButton!
    @IBOutlet weak var prayerSessionTitle: UILabel!
    @IBOutlet weak var prayerSessionDescription: UILabel!
    @IBOutlet weak var prayerSessionDescription2: UILabel!
    @IBOutlet weak var lengthSelector: UISegmentedControl!
    @IBOutlet weak var selectorBar: UIView!
    
    var user = User()
    var prayer: PrayerItem?
    var lengthWasChanged: Bool = false
    
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
        
        let realm = try! Realm() //TODO: Change to do catch - not sure if I need this
        guard let realmUser = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        user = realmUser
        
        if let prayer = self.prayer {
            self.setPrayerSession(withTitle: prayer.title)
            print("SETTING PRAYER SESSION WITH PRAYER: \(prayer.title)")
        } else {
            self.setPrayerSession(withTitle: user.nextPrayerTitle)
            print("SETTING PRAYER SESSION WITHOUT PRAYER: \(user.nextPrayerTitle)")
        }

        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setSelectorBarPosition()
    }
    
    // MARK: - Actions
    
    @IBAction func lengthChanged(_ sender: Any) {
        RealmUtilities.setCurrentAudioTime(withCurrentTime: 0.00)
        let length = self.lengthSelector.titleForSegment(at: self.lengthSelector.selectedSegmentIndex)!
        if length == "5 mins" {
            self.prayer = self.prayer5mins
        } else if length == "15 mins" {
            self.prayer = self.prayer15mins
        } else {
            self.prayer = self.prayer10mins
        }
        print("Prayer length changed: \(length)")

        UIView.animate(withDuration: 0.3) {
            self.setSelectorBarPosition()
        }
    }
    
    // MARK: - Functions
    
    private func setPrayerSession(withTitle title: String) {
        
        let realm = try! Realm() //TODO: Change to do catch - not sure if I need this
        let prayers = realm.objects(PrayerItem.self)
        self.prayer5mins = prayers.filter("title = %@ AND guide = %@ AND length = %@", title, user.guide, "5 mins") [0]
        self.prayer10mins = prayers.filter("title = %@ AND guide = %@ AND length = %@", title, user.guide, "10 mins") [0]
        self.prayer15mins = prayers.filter("title = %@ AND guide = %@ AND length = %@", title, user.guide, "15 mins") [0]

        if let length = self.prayer?.length {
            if length == "5 mins" {
                self.prayer = self.prayer5mins
                self.lengthSelector.selectedSegmentIndex = 0
            } else if length == "15 mins" {
                self.prayer = self.prayer15mins
                self.lengthSelector.selectedSegmentIndex = 2
            } else {
                self.prayer = self.prayer10mins
            }
        } else {
            self.prayer = self.prayer10mins
        }
        
        self.prayerSessionTitle.text = self.prayer!.title
        self.prayerSessionTitle.text?.append(" of 9")
        self.prayerSessionDescription.text = self.prayer!.desc
        
        let description2 = NSMutableAttributedString(string: self.prayer!.desc2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        self.prayerSessionDescription2.attributedText = description2
    }
    
    private func setSelectorBarPosition() {
        let width = self.lengthSelector.frame.width / 3
        let origin = self.lengthSelector.frame.origin.x
        let index = self.lengthSelector.selectedSegmentIndex
        if index == 0 {
            self.selectorBar.frame.origin.x = origin
        } else if index == 1 {
            self.selectorBar.frame.origin.x = origin + width
        } else {
            self.selectorBar.frame.origin.x = origin + 2 * width
        }
    }
    
    // Sets up hud
    // TODO: - do I need to ever hide anything or show a hud?
    
    private func set(isLoading: Bool) {
        self.prayerSessionTitle.isHidden = isLoading
        self.prayerSessionDescription.isHidden = isLoading
        self.prayNowLabel.isHidden = isLoading
        self.lengthSelector.isHidden = isLoading
        self.selectorBar.isHidden = isLoading
        self.prayerSessionDescription2.isHidden = isLoading
        if isLoading {
            self.showLightHud()
        } else {
            self.dismissHud()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController, let AudioPlayerViewController = destination.viewControllers.first as? AudioPlayerViewController {    
                let prayer = self.prayer
                AudioPlayerViewController.prayer = prayer
        }
    }
    
    // MARK: - Design
    
    private func setUpSelector() {
        
        lengthSelector.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Montserrat-Black", size: 18) as Any,
            NSAttributedStringKey.foregroundColor: UIColor(named: "darkIndigo") as Any
            ], for: .normal)
        
        lengthSelector.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont(name: "Montserrat-Black", size: 18) as Any,
            NSAttributedStringKey.foregroundColor: UIColor(named: "fadedPink") as Any
            ], for: .selected)
        
    }
    
    
    
}
