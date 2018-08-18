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
import RealmSwift
import StoreKit

class ReflectViewController: TextBaseViewController {

    @IBOutlet weak var textField: UITextView!
    
    var prayer: Prayer?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 0.5
        textField!.layer.borderColor = UIColor.white.cgColor
        textField.delegate = self
        setUpTextViewDoneButton(textView: textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }

    // MARK: - Actions
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        reflectSegue()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        save()
    }
    
    @IBAction func exitButton(_ sender: Any) {
        reflectSegue()
    }
    
    private func save() {
        guard let entry = textField.text, let prayer = prayer else {
            print("Error in save")
            return
        }
        let prayerTitle = "\(prayer.title) - \(prayer.desc)"
        RealmUtilities.saveJournalEntry(entryText: entry, prayerTitle: prayerTitle)
        reflectSegue()
    }    
        
    private func reflectSegue() {
        guard let user = User.current, let prayer = prayer else {
            print("ERROR in pulling user data - it's nil")
            return
        }
        if user.isFirstDay {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            RealmUtilities.updateIsFirstDay(withIsFirstDay: false)
        } else {
            performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
        }
        
        if prayer.prayerIndex == 9 {
            askForReview()
        }
    }
    
    private func askForReview() {
        let alertController : UIAlertController = UIAlertController(title: "Congratulations on completing Day 9", message: "Have you enjoyed Hallow so far?", preferredStyle: .actionSheet)
        let yesAction : UIAlertAction = UIAlertAction(title: "Definitely!", style: .default, handler: {(cameraAction) in
            print("Definitely selected")
            if #available( iOS 10.3,*){
                SKStoreReviewController.requestReview()
            }
        })
        let noAction : UIAlertAction = UIAlertAction(title: "Nah not that much", style: .default, handler: {(libraryAction) in
            print("No selected")
        })
        alertController.addAction(yesAction)
        alertController.addAction(noAction)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        present(alertController, animated: true, completion: nil)
    }
   
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController {
            destination.selectedIndex = 1
            if let nav = destination.selectedViewController as? UINavigationController {
                if let root = nav.topViewController as? FullJourneyViewController {
                    root.completedSegue = true
                }
            }
        }
    }
}
