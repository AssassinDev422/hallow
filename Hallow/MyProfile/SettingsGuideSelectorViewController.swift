//
//  SettingsGuideSelectorViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsGuideSelectorViewController: UIViewController {
    
    @IBOutlet weak var abbyButton: UIButton!
    @IBOutlet weak var francisButton: UIButton!
    
    var user = User()
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("Error in settings guide selector")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of settings guide selector")
        }
        setGuideButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setGuideButton()
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func francisButton(_ sender: UIButton) {
        francisButton.isSelected = !francisButton.isSelected
        abbyButton.isSelected = !abbyButton.isSelected
        RealmUtilities.updateGuide(withGuide: User.Guide.Francis) { }
        RealmUtilities.setCurrentAudioTime(withCurrentTime: 0.00)
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButton.isSelected = !abbyButton.isSelected
        francisButton.isSelected = !francisButton.isSelected
        RealmUtilities.updateGuide(withGuide: User.Guide.Abby) { }
        RealmUtilities.setCurrentAudioTime(withCurrentTime: 0.00)
    }
    
    // MARK: - Functions
    
    private func setGuideButton() {
        if user.guide == User.Guide.Francis {
            francisButton.isSelected = true
            abbyButton.isSelected = false
        } else {
            francisButton.isSelected = false
            abbyButton.isSelected = true
        }
    }

}
