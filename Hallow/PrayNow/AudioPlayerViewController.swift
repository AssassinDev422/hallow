//
//  AudioPlayerViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

// This is the ui branch v2

import UIKit
import AVFoundation
import FirebaseStorage
import JGProgressHUD
import FirebaseFirestore
import Firebase

class AudioPlayerViewController: UIViewController {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressControlOutlet: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nowPrayingLabel: UILabel!
    @IBOutlet weak var nowPrayingTitleLabel: UILabel!
    @IBOutlet weak var exitButtonOutlet: UIButton!
    
    var prayer: PrayerItem?
    var audioPlayer: AVAudioPlayer?
    
    var handle: AuthStateDidChangeListenerHandle?
    var userID: String?
    
    var controlTimer: Timer?
    
    var alreadySaved = 0
    
    var addedTimeTracker = 0.00
    var stats: StatsItem?
    
    // MARK: - Life cycle
   
    override func viewDidLoad() {
        hideOutlets(shouldHide: true)
        setUpProgressControlUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let prayer = prayer {
            downloadAndSetUpAudio(prayer: prayer)
            print("Prayer title in view did appear of audio player: \(self.prayer!.title)")
            nowPrayingTitleLabel.text = self.prayer?.description
        }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user!.uid
        }
        alreadySaved = 0
        addedTimeTracker = 0.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controlTimer?.invalidate()
        audioPlayer?.currentTime = 0
        audioPlayer?.currentTime = 0
        audioPlayer?.stop()
        progressControlOutlet.setValue(Float(0.0), animated: false)
        updateMyStats()
    }
    
    // MARK: - Actions
    
    @IBAction func pressPlayPause(_ sender: Any) {
        Constants.hasStartedListening = true
        guard let audioPlayer = audioPlayer else {
            setupAudioPlayer(file: prayer)
            return
        }
        if audioPlayer.isPlaying {
            audioPlayer.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        } else {
            audioPlayer.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
        }
        if self.alreadySaved == 0 {
            FirebaseUtilities.saveStartedPrayer(byUserID: self.userID!, withPrayerTitle: self.prayer!.title)
            self.alreadySaved = 1
        }
    }
    
    @IBAction func progressControl(_ sender: Any) {
        print("progressControl function was run")
        sliderUpdatedTime()
    }
    
    @IBAction func exitButtonReleased(_ sender: Any) {
        exitButtonOutlet.setTitleColor(UIColor(named: "beige"), for: .normal)
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        exitButtonOutlet.setTitleColor(UIColor(named: "fadedPink"), for: .normal)
    }
    
    // MARK: - Functions
    
    func downloadAndSetUpAudio(prayer: PrayerItem) {
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: prayer.audioURLPath)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            setupAudioPlayer(file: prayer)
            return
        }
        
        print("attempting to download: \(prayer.audioURLPath)...")
        self.set(isLoading: true)
        let pathReference = Storage.storage().reference(withPath: prayer.audioURLPath)
        
        let downloadTask = pathReference.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(prayer.audioURLPath)")
                self.setupAudioPlayer(file: prayer)
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
    
    func setupAudioPlayer(file: PrayerItem?) {
        guard let file = file else {
            print("File was not set in audio player")
            return
        }
        
        let audioURL = Utilities.urlInDocumentsDirectory(forPath: file.audioURLPath)
        
        // Setup AVPlayer
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            print("Audio player was set up")
            //FIXME: Update title on screen - self.navigationItem.title = self.prayer!.title
            self.set(isLoading: false)
            updateProgressControl(songCompleted: completionHandler)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Functions - Progress Control
    
    private func updateProgressControl(songCompleted: @escaping (Bool) -> Void) {
        if audioPlayer != nil {
            controlTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
                let percentComplete = self!.audioPlayer!.currentTime / self!.audioPlayer!.duration
                self?.progressControlOutlet.setValue(Float(percentComplete), animated: true)
                
                let time = self!.audioPlayer!.currentTime
                let minutes = Int(time) / 60 % 60
                let seconds = Int(time) % 60
                self?.timeLabel.text = String(format:"%01i:%02i", minutes, seconds)
                
                self?.timeLabel.frame.origin.x = 5 + CGFloat(percentComplete) * (self?.progressControlOutlet.frame.width)!
                
                if self?.audioPlayer?.isPlaying == true {
                    self?.addedTimeTracker += 0.01
                }
                if percentComplete > 0.999 {
                    print("if statement at the end of the song executed")
                    songCompleted(true)
                } else {
                    songCompleted(false)
                }
            }
        } else {
            setupAudioPlayer(file: prayer)
            print("Audio player is nil")
            return
        }
    }
    
    lazy var completionHandler: (Bool) -> Void = {
        if $0 {
            print("Ran completion handler")
            self.controlTimer?.invalidate()
            self.audioPlayer!.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            self.performSegue(withIdentifier: "reflectSegue", sender: self)
            FirebaseUtilities.saveCompletedPrayer(byUserID: self.userID!, withPrayerTitle: self.prayer!.title)
        }
    }
    
    private func sliderUpdatedTime() {
        if audioPlayer != nil {
            let percentComplete = progressControlOutlet.value
            audioPlayer?.currentTime = TimeInterval(percentComplete * Float(audioPlayer!.duration))
        } else {
            setupAudioPlayer(file: prayer)
            print("Audio player is nil")
            return
        }
    }
    
    // MARK: - Functions - Stats
    
    private func updateMyStats() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUser: self.userID!) { results in
            print("Results: \(results)")
            if results == [] {
                print("No results file existed")
                print("Time updated to: \(self.addedTimeTracker)")
                FirebaseUtilities.saveStats(byUserID: self.userID!, withTimeInPrayer: self.addedTimeTracker)
            } else {
                self.stats = results.map(StatsItem.init)[0]
                if let stats = self.stats {
                    print("time loaded: \(stats.timeInPrayer)")
                    stats.timeInPrayer += self.addedTimeTracker
                    print("time updated: \(stats.timeInPrayer)")
                    FirebaseUtilities.deleteFile(ofType: "stats", byUser: self.userID!, withID: stats.docID!)
                    FirebaseUtilities.saveStats(byUserID: self.userID!, withTimeInPrayer: stats.timeInPrayer)
                } else {
                    print("Error: stats is nil")
                }
            }
        }
    }
    
    // MARK: - Functions - Hud and outlets
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.indicatorView = JGProgressHUDRingIndicatorView() //Can change to JGProgressHUDPieIndicatorView()
        hud.interactionType = .blockAllTouches
        hud.detailTextLabel.text = "0% Complete"
        hud.textLabel.text = "Downloading"
        return hud
    }()
    
    private func set(isLoading: Bool) {
        hideOutlets(shouldHide: isLoading)
        if isLoading {
            self.hud.show(in: view, animated: false)
        } else {
            self.hud.dismiss(animated: true)
        }
    }
    
    private func hideOutlets(shouldHide: Bool) {
        self.playPauseButton.isHidden = shouldHide
        self.progressControlOutlet.isHidden = shouldHide
        self.exitButtonOutlet.isHidden = shouldHide
        self.timeLabel.isHidden = shouldHide
        self.nowPrayingLabel.isHidden = shouldHide
        self.nowPrayingTitleLabel.isHidden = shouldHide
    }
    
    // MARK: - Design
    
    private func setUpProgressControlUI() {
        let image = #imageLiteral(resourceName: "thumbIcon")
        let newWidth = 2
        let newHeight = 5
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        progressControlOutlet.setThumbImage(thumbImage, for: .normal)
        
        progressControlOutlet.transform = progressControlOutlet.transform.scaledBy(x: 1, y: 2)
        progressControlOutlet.tintColor = UIColor(named: "fadedPink")
    }
}
