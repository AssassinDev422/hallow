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

// TODO: Weird blip after it finishes a song

class GuideSelectorViewController: UIViewController {
    
    @IBOutlet weak var francisButtonOutlet: UIButton!
    @IBOutlet weak var abbyButtonOutlet: UIButton!
    @IBOutlet weak var francisPlaySampleOutlet: UIButton! //TODO: Might have to delete
    @IBOutlet weak var abbyPlaySampleOutlet: UIButton! //TODO: Might have to delete
    
    var francisIsPlaying: Bool = false
    var abbyIsPlaying: Bool = false
    var francisFirstPlay: Bool = true
    var abbyFirstPlay: Bool = true
    
    var francisSampleAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    var francisSampleAudioURLPath: String = "audio/day_1.mp3"
    var abbySampleAudioPlayer: AVAudioPlayer = AVAudioPlayer()
    var abbySampleAudioURLPath: String = "audio/day_2.mp3"
    
    var francisTimer: Timer?
    var abbyTimer: Timer?

    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        francisButtonOutlet.isSelected = !francisButtonOutlet.isSelected
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
    
    // MARK: - Actions
    
    @IBAction func francisButton(_ sender: UIButton) {
        francisButtonOutlet.isSelected = !francisButtonOutlet.isSelected
        abbyButtonOutlet.isSelected = !abbyButtonOutlet.isSelected
        Constants.guide = "Francis"
        print("guide selected: \(Constants.guide)")
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButtonOutlet.isSelected = !abbyButtonOutlet.isSelected
        francisButtonOutlet.isSelected = !francisButtonOutlet.isSelected
        Constants.guide = "Abby"
        print("guide selected: \(Constants.guide)")
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
        self.set(isLoading: true)
        let pathReference = Storage.storage().reference(withPath: audioURLPath)
        
        let downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(audioURLPath)")
                self.setupFrancisAudioPlayer(audioURLPath: audioURLPath)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            // Update the progress indicator
            self.hud.progress = Float(percentComplete)/100.0
            if percentComplete > 1.0 {
                let percentCompleteRound = String(format: "%.0f", percentComplete)
                self.hud.detailTextLabel.text = "\(percentCompleteRound)% Complete"
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
            
            print("Francis audio player was set up")
            self.set(isLoading: false)
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
        self.set(isLoading: true)
        let pathReference = Storage.storage().reference(withPath: audioURLPath)
        
        let downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(audioURLPath)")
                self.setupAbbyAudioPlayer(audioURLPath: audioURLPath)
            }
        }
        
        downloadTask.observe(.progress) { snapshot in
            // Download reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            // Update the progress indicator
            self.hud.progress = Float(percentComplete)/100.0
            if percentComplete > 1.0 {
                let percentCompleteRound = String(format: "%.0f", percentComplete)
                self.hud.detailTextLabel.text = "\(percentCompleteRound)% Complete"
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
            
            print("Abby audio player was set up")
            self.set(isLoading: false)
            checkAbbyProgress(abbySongCompleted: abbyCompletionHandler)
            abbyPlayToggle()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Functions - Play toggles
    
    private func francisPlayToggle() {
        if francisIsPlaying == false {
            francisPlaySampleOutlet.setTitle("Pause", for: .normal)
            francisSampleAudioPlayer.play()
            francisIsPlaying = true
            if abbyIsPlaying == true {
                abbyPlaySampleOutlet.setTitle("Play", for: .normal)
                abbySampleAudioPlayer.pause()
                abbyIsPlaying = false
            }
        } else {
            francisPlaySampleOutlet.setTitle("Play", for: .normal)
            francisSampleAudioPlayer.pause()
            francisIsPlaying = false
        }
    }
    
    private func abbyPlayToggle() {
        if abbyIsPlaying == false {
            abbyPlaySampleOutlet.setTitle("Pause", for: .normal)
            abbySampleAudioPlayer.play()
            abbyIsPlaying = true
            if francisIsPlaying == true {
                francisPlaySampleOutlet.setTitle("Play", for: .normal)
                francisSampleAudioPlayer.pause()
                francisIsPlaying = false
            }
        } else {
            abbyPlaySampleOutlet.setTitle("Play", for: .normal)
            abbySampleAudioPlayer.pause()
            abbyIsPlaying = false
        }
    }
    
    // MARK: - Functions - Check progress
    
    private func checkFrancisProgress(francisSongCompleted: @escaping (Bool) -> Void) {
        francisTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            let percentComplete = self!.francisSampleAudioPlayer.currentTime / self!.francisSampleAudioPlayer.duration
            if percentComplete > 0.999 {
                print("if statement at the end of the song executed")
                francisSongCompleted(true)
            } else {
                francisSongCompleted(false)
            }
        }
    }
    
    lazy var francisCompletionHandler: (Bool) -> Void = {
        if $0 {
            print("Ran completion handler")
            self.francisSampleAudioPlayer.pause()
            self.francisPlaySampleOutlet.setTitle("Play", for: .normal)
            self.francisSampleAudioPlayer.currentTime = 0.0
        }
    }
    
    private func checkAbbyProgress(abbySongCompleted: @escaping (Bool) -> Void) {
        abbyTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
            let percentComplete = self!.abbySampleAudioPlayer.currentTime / self!.abbySampleAudioPlayer.duration
            if percentComplete > 0.999 {
                print("if statement at the end of the song executed")
                abbySongCompleted(true)
            } else {
                abbySongCompleted(false)
            }
        }
    }
    
    lazy var abbyCompletionHandler: (Bool) -> Void = {
        if $0 {
            print("Ran completion handler")
            self.abbySampleAudioPlayer.pause()
            self.abbyPlaySampleOutlet.setTitle("Play", for: .normal)
            self.abbySampleAudioPlayer.currentTime = 0.0
        }
    }
    
    
    // MARK: - Functions - Set up hud
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDRingIndicatorView() //Can change to JGProgressHUDPieIndicatorView()
        hud.interactionType = .blockAllTouches
        hud.detailTextLabel.text = "0% Complete"
        hud.textLabel.text = "Downloading"
        return hud
    }()
    
    private func set(isLoading: Bool) {
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: true)
        }
    }
    
}
