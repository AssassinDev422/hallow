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

class FeedbackViewController: TextBaseViewController {
    
    @IBOutlet weak var titleField: UILabel! // We appreciate the feedback!
    @IBOutlet weak var feedbackField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTextViewDoneButton(textView: feedbackField)
        feedbackField.delegate = self
        feedbackField?.layer.borderWidth = 0
        feedbackField?.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        navigationItem.title = "Send Feedback"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleField.text = "We appreciate the feedback!"
        hideToggle(isHidden: false)
        ReachabilityManager.shared.addListener(listener: self)
        feedbackField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Functions
    
    private func hideToggle(isHidden: Bool) {
        feedbackField.isHidden = isHidden
        sendButton.isHidden = isHidden
    }
    
    // MARK: - Actions
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        guard let user = User.current, let entry = feedbackField.text else {
            print("Error in sendButtonPressed")
            return
        }
        FirebaseUtilities.saveOtherData(ofType: "Feedback", byUserEmail: user.email, withEntry: entry)
        titleField.text = "Successfully submitted - thanks!"
        hideToggle(isHidden: true)
    }
}
