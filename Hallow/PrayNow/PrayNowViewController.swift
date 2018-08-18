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

class PrayNowViewController: BaseViewController {
    
    @IBOutlet weak var prayNowLabel: UIButton!
    @IBOutlet weak var prayerSessionTitle: UILabel!
    @IBOutlet weak var prayerSessionDescription: UILabel!
    @IBOutlet weak var prayerSessionDescription2: UILabel!
    @IBOutlet weak var lengthSelector: UISegmentedControl!
    @IBOutlet weak var selectorBar: UIView!
    
    var prayer: Prayer?
    var prayer10mins: Prayer?
    var prayer5mins: Prayer?
    var prayer15mins: Prayer?
    var lengthWasChanged: Bool = false
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSelector()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let user = User.current else {
            print("ERROR in pulling user data - it's nil")
            return
        }
        if let prayer = prayer {
            setPrayerSession(withIndex: prayer.prayerIndex)
        } else {
            setPrayerSession(withIndex: user.nextPrayerIndex)
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
        Utilities.pausedTime = 0.00
        guard let length = lengthSelector.titleForSegment(at: lengthSelector.selectedSegmentIndex) else {
            print("Error in lengthChanged")
            return
        }
        if length == "5 mins" {
            prayer = prayer5mins
        } else if length == "15 mins" {
            prayer = prayer15mins
        } else {
            prayer = prayer10mins
        }
        UIView.animate(withDuration: 0.3) {
            self.setSelectorBarPosition()
        }
    }
    
    // MARK: - Functions
    
    private func setPrayerSession(withIndex prayerIndex: Int) {
        do {
            guard let user = User.current else {
                print("ERROR in pulling user data - it's nil")
                return
            }
            let realm = try Realm()
            let prayers = realm.objects(Prayer.self)
            prayer5mins = prayers.filter("prayerIndex = %@ AND guide = %@ AND length = %@", prayerIndex, user._guide, "5 mins").first
            prayer10mins = prayers.filter("prayerIndex = %@ AND guide = %@ AND length = %@", prayerIndex, user._guide, "10 mins").first
            prayer15mins = prayers.filter("prayerIndex = %@ AND guide = %@ AND length = %@", prayerIndex, user._guide, "15 mins").first
        } catch {
            print("REALM: Error loading prayers in praynow")
        }

        if let length = prayer?.length {
            if length == "5 mins" {
                prayer = prayer5mins
                lengthSelector.selectedSegmentIndex = 0
            } else if length == "15 mins" {
                prayer = prayer15mins
                lengthSelector.selectedSegmentIndex = 2
            } else {
                prayer = prayer10mins
            }
        } else {
            prayer = prayer10mins
        }
        
        guard let prayer = prayer else {
            print("Error in setPrayerSession")
            return
        }
        prayerSessionTitle.text = prayer.title
        prayerSessionDescription.text = prayer.desc
        
        let description2 = NSMutableAttributedString(string: prayer.desc2)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        description2.addAttribute(NSAttributedStringKey.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, description2.length))
        prayerSessionDescription2.attributedText = description2
    }
    
    private func setSelectorBarPosition() {
        let width = lengthSelector.frame.width / 3
        let origin = lengthSelector.frame.origin.x
        let index = lengthSelector.selectedSegmentIndex
        if index == 0 {
            selectorBar.frame.origin.x = origin
        } else if index == 1 {
            selectorBar.frame.origin.x = origin + width
        } else {
            selectorBar.frame.origin.x = origin + 2 * width
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UINavigationController, let AudioPlayerViewController = destination.viewControllers.first as? AudioPlayerViewController, let prayer = self.prayer {
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
