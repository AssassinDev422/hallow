//
//  FeedbackViewController.swift
//  Hallow
//
//  Created by Alex Jones on 6/14/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Firebase

class FeedbackViewController: UIViewController {
    
    @IBOutlet weak var feedbackField: UITextView!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        feedbackField!.layer.borderWidth = 0
        feedbackField!.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        
        feedbackField!.layer.masksToBounds = false
        feedbackField!.layer.shadowColor = UIColor.lightGray.cgColor
        feedbackField!.layer.shadowOpacity = 0.8
        feedbackField!.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        feedbackField!.layer.shadowRadius = 2
        
        navigationItem.title = "Send Feedback"
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
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let entry = feedbackField!.text
        FirebaseUtilities.sendFeedback(ofType: "feedback", byUserID: self.userID!, withEntry: entry!)
    }

}
