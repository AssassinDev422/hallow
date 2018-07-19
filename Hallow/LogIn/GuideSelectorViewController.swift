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

class GuideSelectorViewController: AudioController {
    
    @IBOutlet weak var francisButton: UIButton!
    @IBOutlet weak var abbyButton: UIButton!
    @IBOutlet weak var francisPlaySampleButton: UIButton!
    @IBOutlet weak var abbyPlaySampleButton: UIButton! 
    
    var firstPlay: Bool = true
    var isPlaying: Bool = false
    
//    var audioPlayer: AVAudioPlayer = AVAudioPlayer()
//    var timer: Timer?
        
    enum Guide: String {
        case Francis = "audio/Samples - F.mp3"
        case Abby = "audio/Samples - A.mp3"
    }
    
    var guidePlaying: GuideSelectorViewController.Guide?
    
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        francisButton.isSelected = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.audioPlayer?.currentTime = 0
        self.audioPlayer?.stop()
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
        if firstPlay == false {
            audioPlayer?.stop()
        }
        downloadAndSetUpAudio(guide: Guide.Francis)
        firstPlay = false
    }
    
    @IBAction func abbyPlaySample(_ sender: UIButton) {
        if firstPlay == false {
            audioPlayer?.stop()
        }
        downloadAndSetUpAudio(guide: Guide.Abby)
        firstPlay = false
    }
    
    // MARK: - Functions
        
    private func downloadAndSetUpAudio(guide: GuideSelectorViewController.Guide) {
        let audioURLPath = guide.rawValue
        
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: audioURLPath)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            setupAudioPlayer(guide: guide)
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
                self.setupAudioPlayer(guide: guide)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            guard let progress = snapshot.progress else {
                print("Error updating progress")
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
    
    func setupAudioPlayer(guide: GuideSelectorViewController.Guide) {
        let audioURLPath = guide.rawValue
        
        let audioURL = Utilities.urlInDocumentsDirectory(forPath: audioURLPath)
        
        // Setup AVPlayer
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            audioPlayer.delegate = self
            
            dismissHud()
            playToggle(guide: guide)
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Functions - Play toggle
    
    private func playToggle(guide: GuideSelectorViewController.Guide) { //TODO: Might be able to switch isPlaying
        switch guide {
        case .Francis:
            if isPlaying == true, guidePlaying == Guide.Abby {
                abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                audioPlayer.stop()
                isPlaying = false
                downloadAndSetUpAudio(guide: Guide.Francis)
            } else {
                if isPlaying == false {
                    francisPlaySampleButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
                    audioPlayer.play()
                    isPlaying = true
                    guidePlaying = Guide.Francis
                } else {
                    francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                    audioPlayer.pause()
                    isPlaying = false
                }
            }
        case .Abby:
            if isPlaying == true, guidePlaying == Guide.Francis {
                francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                audioPlayer.stop()
                isPlaying = false
                downloadAndSetUpAudio(guide: Guide.Abby)
            } else {
                if isPlaying == false {
                    abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
                    audioPlayer.play()
                    isPlaying = true
                    guidePlaying = Guide.Abby
                } else {
                    abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                    audioPlayer.pause()
                    isPlaying = false
                }
            }
        }
    }
    
    // MARK: - Functions - Check progress
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer.stop()
        self.francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        self.abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        isPlaying = false
    }
}
