//
//  CompletePrayerViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/14/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit

class CompletePrayerViewController: UIViewController {

    @IBAction func prayerJourneyButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }

    @IBAction func viewJournalButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
}
