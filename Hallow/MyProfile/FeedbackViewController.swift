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
import RealmSwift

class FeedbackViewController: JournalBaseViewController {
    
    @IBOutlet weak var feedbackField: UITextView!
    
    var user = User()
        
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDoneButton(textView: feedbackField)
        
        feedbackField.delegate = self
                
        feedbackField!.layer.borderWidth = 0
        feedbackField!.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        
        navigationItem.title = "Send Feedback"
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let realm = try! Realm() //TODO: Change to do catch
        guard let realmUser = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        user = realmUser
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let entry = feedbackField!.text
        FirebaseUtilities.sendFeedback(ofType: "feedback", byUserEmail: user.email, withEntry: entry!)
        self.navigationController?.popViewController(animated: true)
    }

}
