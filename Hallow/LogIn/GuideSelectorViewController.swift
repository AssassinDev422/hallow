//
//  GuideSelectorViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/19/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage
import JGProgressHUD

class GuideSelectorViewController: LogInBaseViewController {
    
    @IBOutlet weak var francisButton: UIButton!
    @IBOutlet weak var abbyButton: UIButton!
    @IBOutlet weak var francisPlaySampleButton: UIButton!
    @IBOutlet weak var abbyPlaySampleButton: UIButton! 
    
    var francisIsPlaying: Bool = false
    var abbyIsPlaying: Bool = false
    var francisFirstPlay: Bool = true
    var abbyFirstPlay: Bool = true
    
    var francisSampleAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    let francisSampleAudioURLPath: String = "audio/Samples - F.mp3"
    var abbySampleAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    let abbySampleAudioURLPath: String = "audio/Samples - A.mp3"
    
    var francisTimer: Timer?
    var abbyTimer: Timer?

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        francisButton.isSelected = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if francisFirstPlay == false {
            francisTimer?.invalidate()
            self.francisSampleAudioPlayer.currentTime = 0
            self.francisSampleAudioPlayer.stop()
        }
        if abbyFirstPlay == false {
            abbyTimer?.invalidate()
            self.abbySampleAudioPlayer.currentTime = 0
            self.abbySampleAudioPlayer.stop()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ReachabilityManager.shared.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    // MARK: - Actions
    
    @IBAction func francisButton(_ sender: UIButton) {
        francisButton.isSelected = !francisButton.isSelected
        abbyButton.isSelected = !abbyButton.isSelected
        Constants.guide = "Francis"
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButton.isSelected = !abbyButton.isSelected
        francisButton.isSelected = !francisButton.isSelected
        Constants.guide = "Abby"
    }
    
    @IBAction func francisPlaySample(_ sender: UIButton) {
        if francisFirstPlay == true {
            downloadAndSetUpFrancisAudio(audioURLPath: francisSampleAudioURLPath)
            francisFirstPlay = false
        } else {
            francisPlayToggle()
        }
    }
    
    @IBAction func abbyPlaySample(_ sender: UIButton) {
        if abbyFirstPlay == true {
            downloadAndSetUpAbbyAudio(audioURLPath: abbySampleAudioURLPath)
            abbyFirstPlay = false
        } else {
            abbyPlayToggle()
        }
    }
    
    // MARK: - Functions
    
    // MARK: - Functions - Set up Francis
    
    private func downloadAndSetUpFrancisAudio(audioURLPath: String) {
        
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: audioURLPath)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            setupFrancisAudioPlayer(audioURLPath: audioURLPath)
            return
        }
        
        print("attempting to download: \(audioURLPath)...")
        showDownloadingHud()
        let pathReference = Storage.storage().reference(withPath: audioURLPath)
        
        let downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
                Utilities.errorAlert(message: "Error downloading file - please try again", viewController: self)
            } else {
                print("downloaded \(audioURLPath)")
                self.setupFrancisAudioPlayer(audioURLPath: audioURLPath)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            guard let progress = snapshot.progress else {
                print("Error updating progress")
                return
            }
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            // Update the progress indicator
            self.hud?.progress = Float(percentComplete)/100.0
            if percentComplete > 1.0 {
                let percentCompleteRound = String(format: "%.0f", percentComplete)
                self.hud?.detailTextLabel.text = "\(percentCompleteRound)% Complete"
            }
        }
    }
    
    func setupFrancisAudioPlayer(audioURLPath: String) {
        
        let audioURL = Utilities.urlInDocumentsDirectory(forPath: audioURLPath)
        
        // Setup AVPlayer
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            francisSampleAudioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            dismissHud()
            checkFrancisProgress(francisSongCompleted: francisCompletionHandler)
            francisPlayToggle()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Functions - Set up Abby
    
    private func downloadAndSetUpAbbyAudio(audioURLPath: String) {
        
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: audioURLPath)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            setupAbbyAudioPlayer(audioURLPath: audioURLPath)
            return
        }
        
        print("attempting to download: \(audioURLPath)...")
        showDownloadingHud()
        let pathReference = Storage.storage().reference(withPath: audioURLPath)
        
        let downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
                Utilities.errorAlert(message: "Error downloading file - please try again", viewController: self)
            } else {
                print("downloaded \(audioURLPath)")
                self.setupAbbyAudioPlayer(audioURLPath: audioURLPath)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            guard let progress = snapshot.progress else {
                print("Error updating progress")
                return
            }
            let percentComplete = 100.0 * Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
            // Update the progress indicator
            self.hud?.progress = Float(percentComplete)/100.0
            if percentComplete > 1.0 {
                let percentCompleteRound = String(format: "%.0f", percentComplete)
                self.hud?.detailTextLabel.text = "\(percentCompleteRound)% Complete"
            }
        }
    }
    
    func setupAbbyAudioPlayer(audioURLPath: String) {
        
        let audioURL = Utilities.urlInDocumentsDirectory(forPath: audioURLPath)
        
        // Setup AVPlayer
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            abbySampleAudioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            dismissHud()
            checkAbbyProgress(abbySongCompleted: abbyCompletionHandler)
            abbyPlayToggle()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Functions - Play toggles
    
    private func francisPlayToggle() {
        if francisIsPlaying == false {
            francisPlaySampleButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
            francisSampleAudioPlayer.play()
            francisIsPlaying = true
            if abbyIsPlaying == true {
                abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                abbySampleAudioPlayer.pause()
                abbyIsPlaying = false
            }
        } else {
            francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            francisSampleAudioPlayer.pause()
            francisIsPlaying = false
        }
    }
    
    private func abbyPlayToggle() {
        if abbyIsPlaying == false {
            abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
            abbySampleAudioPlayer.play()
            abbyIsPlaying = true
            if francisIsPlaying == true {
                francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                francisSampleAudioPlayer.pause()
                francisIsPlaying = false
            }
        } else {
            abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            abbySampleAudioPlayer.pause()
            abbyIsPlaying = false
        }
    }
    
    // MARK: - Functions - Check progress
    
    private func checkFrancisProgress(francisSongCompleted: @escaping (Bool) -> Void) {
        francisTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let percentComplete = self.francisSampleAudioPlayer.currentTime / self.francisSampleAudioPlayer.duration
            if percentComplete > 0.999 {
                francisSongCompleted(true)
            } else {
                francisSongCompleted(false)
            }
        }
    }
    
    lazy var francisCompletionHandler: (Bool) -> Void = {
        if $0 {
            self.francisSampleAudioPlayer.pause()
            self.francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            self.francisSampleAudioPlayer.currentTime = 0.0
        }
    }
    
    private func checkAbbyProgress(abbySongCompleted: @escaping (Bool) -> Void) {
        abbyTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            let percentComplete = self.abbySampleAudioPlayer.currentTime / self.abbySampleAudioPlayer.duration
            if percentComplete > 0.999 {
                abbySongCompleted(true)
            } else {
                abbySongCompleted(false)
            }
        }
    }
    
    lazy var abbyCompletionHandler: (Bool) -> Void = {
        if $0 {
            self.abbySampleAudioPlayer.pause()
            self.abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            self.abbySampleAudioPlayer.currentTime = 0.0
        }
    }
}
