//
//  SettingsGuideSelectorViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit

class SettingsGuideSelectorViewController: UIViewController {
    
    @IBOutlet weak var abbyButtonOutlet: UIButton!
    @IBOutlet weak var francisButtonOutlet: UIButton!
    
    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        if Constants.guide == "Francis" {
            francisButtonOutlet.isSelected = !francisButtonOutlet.isSelected
        } else {
            abbyButtonOutlet.isSelected = !abbyButtonOutlet.isSelected
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func francisButton(_ sender: UIButton) {
        francisButtonOutlet.isSelected = !francisButtonOutlet.isSelected
        abbyButtonOutlet.isSelected = !abbyButtonOutlet.isSelected
        Constants.guide = "Francis"
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButtonOutlet.isSelected = !abbyButtonOutlet.isSelected
        francisButtonOutlet.isSelected = !francisButtonOutlet.isSelected
        Constants.guide = "Abby"
    }

}
