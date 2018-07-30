//
//  ReflectViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

//FIXME: Almost impossible to click the back button

import UIKit
import FirebaseFirestore
import Firebase
import RealmSwift

class ReflectViewController: JournalBaseViewController {

    @IBOutlet weak var textField: UITextView!
    
    var user = User()
    var prayerTitle: String?

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        textField!.layer.borderWidth = 0.5
        textField!.layer.borderColor = UIColor.white.cgColor
        textField.delegate = self
        setUpDoneButton(textView: textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            let realm = try Realm()
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error in will appear of reflect")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of reflect")
        }
        ReachabilityManager.shared.addListener(listener: self)
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
        guard let entry = textField.text, let prayerTitle = prayerTitle else {
            print("Error in save")
            return
        }
        FirebaseUtilities.saveReflection(ofType: "journal", byUserEmail: user.email, withEntry: entry, withTitle: prayerTitle)
        reflectSegue()
    }
        
    private func reflectSegue() {
        if user.isFirstDay {
            performSegue(withIdentifier: "isFirstDaySegue", sender: self)
            RealmUtilities.updateIsFirstDay(withIsFirstDay: false)
        } else {
            performSegue(withIdentifier: "isNotFirstDaySegue", sender: self)
        }
    }
   
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "isNotFirstDaySegue" {
            if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
            }
        } else if let destination = segue.destination as? UITabBarController {
                destination.selectedIndex = 1
        }
    }
}
