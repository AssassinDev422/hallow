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
    
    var startTime = Date(timeIntervalSinceNow: 0)

    func downloadAudio(guide: Constants.Guide, audioURL: String, setLoading: (Bool) -> Void, completionBlock: @escaping (Constants.Guide, String) -> Void) {
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: audioURL)
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
    
    func setupAudioPlayer(guide: Constants.Guide, audioURL: String, setLoading: (Bool) -> Void, updateProgress: () -> Void, playPause: (Constants.Guide) -> Void) {
        setLoading(false)
        
        let audioURL = Utilities.urlInDocumentsDirectory(forPath: audioURL)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // TODO: only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            audioPlayer?.delegate = self
            
            print("Audio player was set up")
            
            playPause(guide)
            
            updateProgress()
            
            audioPlayer?.currentTime = Constants.pausedTime
            
            startTime = Date(timeIntervalSinceNow: 0)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
