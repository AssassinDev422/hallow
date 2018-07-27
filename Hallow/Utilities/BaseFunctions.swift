//
//  BaseFunctions.swift
//  Hallow
//
//  Created by Alex Jones on 7/19/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import Firebase
import FirebaseStorage
import FirebaseFirestore
import MediaPlayer
import AVFoundation
import RealmSwift

// MARK: - Hud

class BaseViewController: UIViewController {
    
    var hud: JGProgressHUD?
    
    func showLightHud() {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        hud.show(in: view, animated: false)
        self.hud = hud
    }
    
    func showDownloadingHud() {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.interactionType = .blockNoTouches
        hud.detailTextLabel.text = "0% Complete"
        hud.textLabel.text = "Downloading"
        hud.show(in: view, animated: false)
        self.hud = hud
    }
    
    func showDownloadingHudBlockTouches() {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.interactionType = .blockAllTouches
        hud.detailTextLabel.text = "0% Complete"
        hud.textLabel.text = "Downloading"
        hud.show(in: view, animated: false)
        self.hud = hud
    }
    
    func dismissHud() {
        self.hud?.dismiss()
    }
    
    func urlInDocumentsDirectory(forPath path: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsDirectory.appendingPathComponent(path)
    }
    
    func updateImage(image: UIImage) -> Void {
        do {
            let path = "profilePicture.jpg"
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
                saveImage(image: image)
            } else {
                print("File does not exist")
                saveImage(image: image)
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
    }
    
    func saveImage(image: UIImage) -> Void {
        let imageURL = urlInDocumentsDirectory(forPath: "profilePicture.jpg")
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            try? imageData.write(to: imageURL, options: .atomic) //TODO: Why atomic?
        }
    }
    
    func loadImage() -> UIImage? {
        let imageURL = urlInDocumentsDirectory(forPath: "profilePicture.jpg")
        do {
            let imageData = try Data(contentsOf: imageURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
    func deleteImage() {
        do {
            let path = "profilePicture.jpg"
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            } else {
                print("File does not exist")
            }
            
        }
        catch let error as NSError {
            print("An error took place: \(error)")
        }
    }
    
    func errorAlert(message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        viewController.present(alert, animated: true)
    }
    
    func alertWithDismiss(viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {_ in
            viewController.dismiss(animated: true, completion: nil)
        }))
        viewController.present(alert, animated: true)
    }
    
}

class BaseTableViewController: UITableViewController {
    
    var hud: JGProgressHUD?
    
    func showLightHud() {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        hud.show(in: view, animated: false)
        self.hud = hud
    }
    
    func showDownloadingHud() {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDRingIndicatorView()
        hud.interactionType = .blockAllTouches
        hud.detailTextLabel.text = "0% Complete"
        hud.textLabel.text = "Downloading"
        hud.show(in: view, animated: false)
        self.hud = hud
    }
    
    func dismissHud() {
        self.hud?.dismiss()
    }
    
}

// MARK: - Text subview edits

class LogInBaseViewController: BaseViewController, UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setUpDoneButton(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

class JournalBaseViewController: BaseViewController, UITextViewDelegate {
    
    var frame: CGRect?
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Did begin editing")
        self.frame = textView.frame
        var newFrame = self.frame!
        newFrame.size.height = self.frame!.height / 2.5
        textView.frame = newFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.frame = self.frame!
    }
    
    func setUpDoneButton(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}

//MARK: - Audio functions

//TODO: - need to set isLoading true before running

class AudioController: BaseViewController, AVAudioPlayerDelegate {
    
    var pathReference: StorageReference?
    var downloadTask: StorageDownloadTask?
    var audioPlayer: AVAudioPlayer?
    
    enum Guide {
        case Francis
        case Abby
    }
    
    var startTime = Date(timeIntervalSinceNow: 0)

    func downloadAudio(guide: Guide, audioURL: String, setLoading: (Bool) -> Void, completionBlock: @escaping (Guide, String) -> Void) {
        let destinationFileURL = urlInDocumentsDirectory(forPath: audioURL)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            completionBlock(guide, audioURL)
            return
        }
        
        print("attempting to download: \(audioURL)...")
        setLoading(true)
        pathReference = Storage.storage().reference(withPath: audioURL)
        
        downloadTask = self.pathReference!.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(audioURL)")
                completionBlock(guide, audioURL)
            }
        }
        
        downloadTask!.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            self.hud?.progress = Float(percentComplete)/100.0
            if percentComplete > 1.0 {
                let percentCompleteRound = String(format: "%.0f", percentComplete)
                self.hud?.detailTextLabel.text = "\(percentCompleteRound)% Complete"
            }
        }
    }
    
    func setupAudioPlayer(guide: Guide, audioURL: String, setLoading: (Bool) -> Void, updateProgress: () -> Void, playPause: (Guide) -> Void) {
        setLoading(false)
        
        let realm = try! Realm() //TODO: Change to do catch
        guard let user = realm.objects(User.self).first else {
            print("Error in realm prayer completed")
            return
        }
        
        let audioURL = urlInDocumentsDirectory(forPath: audioURL)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // TODO: only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            audioPlayer?.delegate = self
            
            print("Audio player was set up")
            
            playPause(guide)
            
            updateProgress()
            
            audioPlayer?.currentTime = user.pausedTime
            
            startTime = Date(timeIntervalSinceNow: 0)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
