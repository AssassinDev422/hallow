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
        hud?.dismiss()
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
        let imageURL = Utilities.urlInDocumentsDirectory(forPath: "profilePicture.jpg")
        if let imageData = UIImageJPEGRepresentation(image, 1.0) {
            try? imageData.write(to: imageURL, options: .atomic) //TODO: Why atomic?
        }
    }
    
    func loadImage() -> UIImage? {
        let imageURL = Utilities.urlInDocumentsDirectory(forPath: "profilePicture.jpg")
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
        hud?.dismiss()
    }
}

// MARK: - Text subview edits

class TextBaseViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
   
    // Text field
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.cornerRadius = 5.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.clear.cgColor
    }
    
    func setUpTextFieldDoneButton(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolBar
    }
    
    @objc func doneClicked() {
        view.endEditing(true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func cleanText(text: String) -> String { //TODO: Check if this works
        let newText = text.trimmingCharacters(in: .whitespaces)
        return newText
    }
    
    // Text View
    
    var frame: CGRect?
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("Did begin editing")
        setTextViewHalfSize(textView)
    }
    
    func setTextViewHalfSize(_ textView: UITextView) {
        frame = textView.frame
        var newFrame = frame!
        newFrame.size.height = frame!.height / 2.5
        textView.frame = newFrame
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.frame = frame!
    }
    
    func setUpTextViewDoneButton(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(doneClicked))
        toolBar.setItems([flexibleSpace, doneButton], animated: false)
        textView.inputAccessoryView = toolBar
    }
}

//MARK: - Audio functions

class AudioController: BaseViewController, AVAudioPlayerDelegate {
    var pathReference: StorageReference?
    var downloadTask: StorageDownloadTask?
    var audioPlayer: AVAudioPlayer?
    var backgroundAudioPlayer: AVAudioPlayer?
    var startTime = Date(timeIntervalSinceNow: 0)

    func downloadAudio(guide: User.Guide, audioURL: String, setLoading: ((Bool) -> Void)? = nil, completionBlock: ((User.Guide, String) -> Void)? = nil) {
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: audioURL)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            completionBlock?(guide, audioURL)
            return
        }
        print("attempting to download: \(audioURL)...")
        setLoading?(true)
        pathReference = Storage.storage().reference(withPath: audioURL)
        
        guard let pathReference = pathReference else {
            print("BASE: Error in downloadAudio")
            return
        }
        downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(audioURL)")
                completionBlock?(guide, audioURL)
            }
        }
        guard let downloadTask = downloadTask else {
            print("BASE: Error in downloadAudio - downloadTask")
            return
        }
        downloadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                print("BASE: Error in downloadAudio - snapShot")
                return
            }
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            self.hud?.progress = Float(percentComplete)/100.0
            if percentComplete > 1.0 {
                let percentCompleteRound = String(format: "%.0f", percentComplete)
                self.hud?.detailTextLabel.text = "\(percentCompleteRound)% Complete"
            }
        }
    }
    
    func setupAudioPlayer(guide: User.Guide, _audioURL: String, setLoading: ((Bool) -> Void)? = nil, updateProgress: (() -> Void)? = nil, playPause: ((User.Guide) -> Void)? = nil) {
        setLoading?(false)
            let audioURL = Utilities.urlInDocumentsDirectory(forPath: _audioURL)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            if _audioURL == Utilities.backgroundAudioURL {
                backgroundAudioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // TODO: May only work for iOS11 - tbd
                backgroundAudioPlayer?.delegate = self
                backgroundAudioPlayer?.play()
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // TODO: May only work for iOS11 - tbd
                audioPlayer?.delegate = self
                playPause?(guide)
                updateProgress?()
                audioPlayer?.currentTime = Utilities.pausedTime
                startTime = Date(timeIntervalSinceNow: 0)
            }
            print("Audio player was set up")
        } catch let error {
            print(error.localizedDescription)
            print("REALM: Error in base functions - setUpAudioPlayer")
        }
    }
}

class AudioTableViewController: BaseTableViewController, AVAudioPlayerDelegate {
    var pathReference: StorageReference?
    var downloadTask: StorageDownloadTask?
    
    func downloadAudio(audioURL: String, loadingButton: UIButton) {
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: audioURL)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            return
        }
        print("attempting to download: \(audioURL)...")
        pathReference = Storage.storage().reference(withPath: audioURL)
        
        guard let pathReference = pathReference else {
            print("BASE: Error in downloadAudio")
            return
        }
        downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(audioURL)")
                loadingButton.setTitle("Remove Download", for: .normal)
            }
        }
        guard let downloadTask = downloadTask else {
            print("BASE: Error in downloadAudio - downloadTask")
            return
        }
        downloadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                print("BASE: Error in downloadAudio - snapShot")
                return
            }
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            let percentCompleteRound = "\(String(format: "%.0f", percentComplete))%"
            loadingButton.setTitle(percentCompleteRound, for: .normal)
        }
    }
}
