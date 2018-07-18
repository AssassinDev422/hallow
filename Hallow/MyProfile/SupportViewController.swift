//
//  SupportViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/14/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController {

    @IBOutlet weak var versionBuildLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Contact & Support"
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String, let bundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String  {
            versionBuildLabel.text = "Version \(version) (\(bundle))"
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

}
