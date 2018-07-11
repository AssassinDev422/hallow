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

class FeedbackViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var feedbackField: UITextView!
    @IBOutlet weak var feedbackTitle: UILabel!
    @IBOutlet weak var buttonOutlet: UIButton!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String?
    
    var frame: CGRect?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpDoneButton()
        
        feedbackField.delegate = self
                
        feedbackField!.layer.borderWidth = 0
        feedbackField!.layer.borderColor = UIColor(named: "fadedPink")?.cgColor
        
        navigationItem.title = "Send Feedback"
    }
    
    // Firebase listener
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
        }
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let entry = feedbackField!.text
        FirebaseUtilities.sendFeedback(ofType: "feedback", byUserEmail: self.userEmail!, withEntry: entry!)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Design
    
    // Add done button to keyboard
    
    private func setUpDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        feedbackField.inputAccessoryView = toolBar
    }
    
    @objc private func doneClicked() {
        view.endEditing(true)
    }
    
    // Change height of textview
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.frame = textView.frame
        var newFrame = self.frame!
        newFrame.size.height = self.frame!.height / 2.5
        textView.frame = newFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.frame = self.frame!
    }

}
