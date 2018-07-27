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
import RealmSwift

//TODO: Add privacy, terms and conditions
//FIXME: Error if I say no to camera allow

class MyProfileViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var minsNumber: UILabel!
    @IBOutlet weak var completedNumber: UILabel!
    @IBOutlet weak var streakNumber: UILabel!
    
    var user = User()
    
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
        
        profilePicture = loadImage()
        
        profileImage.image = profilePicture
        formatProfilePicture()
        
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
        
        self.nameLabel.text = user.name
        self.completedNumber.text = String(user.completedPrayers.count - 1)
        let minutes = user.timeInPrayer / 60.0
        self.minsNumber.text = String(format: "%.0f", minutes)
        self.streakNumber.text = String(user.streak)
        ReachabilityManager.shared.addListener(listener: self)
        
        profilePicture = loadImage()
        profileImage.image = profilePicture
        formatProfilePicture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions

    @IBAction func logOut(_ sender: Any) {
        showLightHud()
        FirebaseUtilities.syncUserData() { //TODO: Not sure if this can have an input as 2 functions
            RealmUtilities.deleteUser()
            self.deleteImage()
            FirebaseUtilities.logOut(viewController: self) {
                self.dismissHud()
                self.performSegue(withIdentifier: "signOutSegue", sender: self)
            }
        }
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        
        let alertController : UIAlertController = UIAlertController(title: "Select source", message: "Select Camera or Photo Library", preferredStyle: .actionSheet)
        let cameraAction : UIAlertAction = UIAlertAction(title: "Camera", style: .default, handler: {(cameraAction) in
            print("camera Selected...")
            
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) == true {
                self.imagePicker.sourceType = .camera
                self.present()
            } else {
                self.errorAlert(message: "Camera is not available on this Device or accesibility has been revoked", viewController: self)
            }
        })
        
        let libraryAction : UIAlertAction = UIAlertAction(title: "Photo Library", style: .default, handler: {(libraryAction) in
            print("Photo library selected....")
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) == true {
                self.imagePicker.sourceType = .photoLibrary
                self.present()
            } else {
                self.errorAlert(message: "Camera is not available on this Device or accesibility has been revoked", viewController: self)
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
        
        profileImage.image = self.profilePicture
        
        formatProfilePicture()
        
        FirebaseUtilities.uploadProfilePicture(withImage: self.profilePicture!, byUserEmail: user.email)
        updateImage(image: self.profilePicture!)
        
        self.imagePicker.dismiss(animated: true, completion: nil)
        
    }
    
    private func formatProfilePicture() {
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.borderWidth = 1
        profileImage.layer.borderColor = UIColor.clear.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
    }    
}
