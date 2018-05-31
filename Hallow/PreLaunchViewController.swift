//
//  PreLaunchViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/24/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

class PreLaunchViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)  //TODO: Screens switch looks weird - should change to appDelegate
            } else {
                print("No user is logged in")
            }
        }
    }

}
