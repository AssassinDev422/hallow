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
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
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
        RealmUtilities.updateGuide(withGuide: User.Guide.francis)
        Utilities.pausedTime = 0.00
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButton.isSelected = !abbyButton.isSelected
        francisButton.isSelected = !francisButton.isSelected
        RealmUtilities.updateGuide(withGuide: User.Guide.abby)
        Utilities.pausedTime = 0.00
    }
    
    // MARK: - Functions
    
    private func setGuideButton() {
        guard let user = User.current else {
            print("ERROR in pulling user data - it's nil")
            return
        }
        if user.guide == User.Guide.francis {
            francisButton.isSelected = true
            abbyButton.isSelected = false
        } else {
            francisButton.isSelected = false
            abbyButton.isSelected = true
        }
    }

}
