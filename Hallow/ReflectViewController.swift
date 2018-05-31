//
//  ReflectViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class ReflectViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 1
        textField!.layer.borderColor = UIColor.black.cgColor
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }

    // MARK: - Actions

    @IBAction func saveButton(_ sender: Any) {
        let entry = textField!.text
        
        FirebaseUtilities.saveReflection(ofType: "journal", byUserID: self.userID!, withEntry: entry!)
        
        if Constants.isFirstDay == true {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            Constants.isFirstDay = false
        } else {
            performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
        }
    }
    
}
