//
//  LaunchViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var signUpOutlet: UIButton!
    @IBOutlet weak var signInOutlet: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideOutlets(shouldHide: true)
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "alreadySignedInSegue", sender: self)
            } else {
                self.hideOutlets(shouldHide: false)
                print("no one is logged in")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    // MARK: - Functions
    // Created so when the segue skips past this screen (when user is already logged in) it doesn't show the buttons
    
    private func hideOutlets(shouldHide: Bool) {
        self.signInOutlet.isHidden = shouldHide
        self.signUpOutlet.isHidden = shouldHide
    }
    
    // MARK: - Design
    
    private func setUpUI() {
        //signUpOutlet.font = UIFont(name: "AcuminPro-Regular", size: 21)!
    }
    
}
