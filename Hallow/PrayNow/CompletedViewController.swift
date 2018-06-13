//
//  CompletedViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/13/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit

class CompletedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "repeatPrayerSegue", let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
                print("prepare for segue happened")
        }
    }

}
