//
//  MyProfileViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/21/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

//TODO: Add privacy, terms and conditions

class MyProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var topBorderOutlet: UIImageView!
    @IBOutlet weak var haloOutlet: UIImageView!
    @IBOutlet weak var profileOutlet: UIImageView!
    @IBOutlet weak var containerOutlet: UIView!
    
    @IBOutlet weak var nameOutlet: UILabel!
    @IBOutlet weak var logOutOutlet: UIButton!

    @IBOutlet weak var uploadImageOutlet: UIButton!
    
    @IBOutlet weak var minsNumber: UILabel!
    @IBOutlet weak var minsLabel: UILabel!

    @IBOutlet weak var completedNumber: UILabel!
    @IBOutlet weak var completedLabel: UILabel!
    
    @IBOutlet weak var streakNumber: UILabel!
    @IBOutlet weak var streakLabel: UILabel!
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    var userEmail: String? 
    
    var storedUserID: String?
    var storedUserEmail: String?
    
    var newFirebaseDocID: String?

    var numberLoading = 4
    
    var imagePicker : UIImagePickerController = UIImagePickerController()
    var profilePicture : UIImage?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "fadedPink")
        imagePicker.delegate = self
        
        let image = LocalFirebaseData.profilePicture
        profilePicture = image
        profileOutlet.image = profilePicture
        formatProfilePicture()
        
    }

    // Firebase listener

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userEmail = user?.email
            if let user = user?.uid {
                self.userID = user
                self.nameOutlet.text = LocalFirebaseData.name
                self.completedNumber.text = String(LocalFirebaseData.completed)
                let minutes = LocalFirebaseData.timeTracker / 60.0
                let minutesString = String(format: "%.0f", minutes)
                self.minsNumber.text = minutesString
                self.streakNumber.text = String(LocalFirebaseData.streak)
            }
        }
        ReachabilityManager.shared.addListener(listener: self)
        
        let image = LocalFirebaseData.profilePicture
        profilePicture = image
        profileOutlet.image = profilePicture
        formatProfilePicture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions

    @IBAction func logOut(_ sender: Any) {
        self.set(isSigningOut: true)
        self.storedUserID = self.userID
        self.storedUserEmail = self.userEmail
        Constants.hasLoggedOutOnce = true
        updateConstants(withID: Constants.firebaseDocID, ofType: "constants", byUserEmail: self.storedUserEmail!, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        
        let alertController : UIAlertController = UIAlertController(title: "Select source", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
        let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
            print("camera Selected...")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
                self.imagePicker.sourceType = .camera
                self.present()
            } else {
                self.present(self.showAlert(Title: "Error", Message: "Camera is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
            }
        })
        
        let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(libraryAction) in
            print("Photo library selected....")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == true {
                self.imagePicker.sourceType = .photoLibrary
                self.present()
            } else {
                self.present(self.showAlert(Title: "Error", Message: "Photo Library is not available on this Device or accesibility has been revoked!"), animated: true, completion: nil)
            }
        })
        
        let cancelAction : UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel , handler: {(cancelActn) in
            print("Cancel action was pressed")
        })
        
        alertController.addAction(cameraAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Functions - Image picker

    private func present() {
        self.present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("info of the pic reached :\(info) ")
        self.profilePicture = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        profileOutlet.image = self.profilePicture
        LocalFirebaseData.profilePicture = self.profilePicture!
        formatProfilePicture()
        
        FirebaseUtilities.uploadProfilePicture(withImage: self.profilePicture!, byUserEmail: self.userEmail!)
        
        self.imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    private func formatProfilePicture() {
        profileOutlet.contentMode = .scaleAspectFill
        profileOutlet.layer.borderWidth = 1
        profileOutlet.layer.masksToBounds = false
        profileOutlet.layer.borderColor = UIColor.clear.cgColor
        profileOutlet.layer.cornerRadius = profileOutlet.frame.height/2
        profileOutlet.clipsToBounds = true
    }

    private func showAlert(Title : String!, Message : String!)  -> UIAlertController {
        let alertController : UIAlertController = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let okAction : UIAlertAction = UIAlertAction(title: "Ok", style: .default) { (alert) in
            print("User pressed ok function")
        }
        alertController.addAction(okAction)
        alertController.popoverPresentationController?.sourceView = view
        alertController.popoverPresentationController?.sourceRect = view.frame
        
        return alertController
    }
    
    private func updateConstants(withID docID: String, ofType type: String, byUserEmail userEmail: String, guide: String, isFirstDay: Bool, hasCompleted: Bool, hasSeenCompletionScreen: Bool, hasStartedListening: Bool, hasLoggedOutOnce: Bool) {
        let db = Firestore.firestore()
        let formatterStored = DateFormatter()
        formatterStored.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let dateStored = formatterStored.string(from: NSDate() as Date)
        
        db.collection("user").document(userEmail).collection(type).document(docID).updateData([
            "Date Stored": dateStored,
            "guide": guide,
            "isFirstDay": isFirstDay,
            "hasCompleted": hasCompleted,
            "hasSeenCompletionScreen": hasSeenCompletionScreen,
            "hasStartedListening": hasStartedListening,
            "hasLoggedOutOnce": hasLoggedOutOnce,
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document updated with user: \(userEmail)")
                }
        }
        self.firebaseLogOut()
    }

    // MARK: - Functions - other functions
    
    private func firebaseLogOut() {
        do {
            try Auth.auth().signOut()
            self.resetLocalFirebaseData()
        } catch let error {
            print(error.localizedDescription)
            self.errorAlert(message: "\(error.localizedDescription)")
        }
    }
    
    private func resetLocalFirebaseData() {
        Constants.hasLoggedOutOnce = true
        Constants.guide = "Francis"
        Constants.isFirstDay = false
        Constants.hasCompleted = false
        Constants.hasSeenCompletionScreen = false
        Constants.hasStartedListening = false
        Constants.hasLoggedOutOnce = false
        
        LocalFirebaseData.completedPrayers = []
        LocalFirebaseData.nextPrayerTitle = "Day 1"
        LocalFirebaseData.name = ""
        LocalFirebaseData.timeTracker = 0.0
        LocalFirebaseData.started = 0
        LocalFirebaseData.completed = 0
        LocalFirebaseData.streak = 0
        LocalFirebaseData.profilePicture = #imageLiteral(resourceName: "profileWithCircle")
        
        self.set(isSigningOut: false)
        self.performSegue(withIdentifier: "signOutSegue", sender: self)
    }
    
    private func errorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // Sets up hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .extraLight)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    private func set(isSigningOut: Bool) {
        if isSigningOut {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: false)
        }
    }
    
}
