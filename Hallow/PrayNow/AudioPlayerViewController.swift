//
//  AudioPlayerViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

// This is now the master branch

// Comment - test for merge

import UIKit
import AVFoundation
import FirebaseStorage
import JGProgressHUD
import FirebaseFirestore
import Firebase
import MediaPlayer

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
    var userEmail: String? 
    
    var controlTimer: Timer?
    
    var alreadySaved = 0
    
    var addedTimeTracker = 0.00
    var streak: Int = 0
    var stats: StatsItem?
    
    var readyToPlay = false
    
    var pathReference: StorageReference?
    var downloadTask: StorageDownloadTask?
    
    var completedPrayers: [PrayerTracking] = []
    
    var nowPlayingInfo = [String : Any]()
    
    // MARK: - Life cycle
   
    override func viewDidLoad() {
        hideOutlets(shouldHide: true)
        setUpProgressControlUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        readyToPlay = false
        if let prayer = prayer {
            downloadAndSetUpAudio(prayer: prayer)
            nowPrayingTitleLabel.text = self.prayer?.description
        }
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            self.userID = user?.uid
            self.userEmail = user?.email
            if self.readyToPlay == false {
                self.readyToPlay = true
            } else {
                self.playPause()
            }
        }
        alreadySaved = 0
        addedTimeTracker = 0.0
        ReachabilityManager.shared.addListener(listener: self)
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(playPause))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Auth.auth().removeStateDidChangeListener(handle!)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controlTimer?.invalidate()
        audioPlayer?.currentTime = 0
        audioPlayer?.currentTime = 0
        audioPlayer?.stop()
        progressControlOutlet.setValue(Float(0.0), animated: false)
        if let email = self.userEmail {
            FirebaseUtilities.updateConstantsFile(withDocID: Constants.firebaseDocID, byUserEmail: email, guide: Constants.guide, isFirstDay: Constants.isFirstDay, hasCompleted: Constants.hasCompleted, hasSeenCompletionScreen: Constants.hasSeenCompletionScreen, hasStartedListening: Constants.hasStartedListening, hasLoggedOutOnce: Constants.hasLoggedOutOnce)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func pressPlayPause(_ sender: Any) {
        playPause()
    }
    
    @IBAction func progressControl(_ sender: Any) {
        sliderUpdatedTime()
    }
    
    @IBAction func exitButtonReleased(_ sender: Any) {
        if self.downloadTask != nil {
            self.downloadTask?.cancel()
            print("Canceled download")
        }
        updateOnlyTimeStat()
        exitButtonOutlet.setTitleColor(UIColor(named: "beige"), for: .normal)
        performSegue(withIdentifier: "exitSegue", sender: prayer)
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        exitButtonOutlet.setTitleColor(UIColor(named: "fadedPink"), for: .normal)
    }
    
    // MARK: - Functions
    
    private func setUpLockScreenInfo() {
        nowPlayingInfo[MPMediaItemPropertyTitle] = "\(prayer?.title ?? "") - \(prayer?.description ?? "")"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioPlayer?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] =  self.audioPlayer?.duration
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc private func playPause() {
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
            FirebaseUtilities.saveStartedPrayer(byUserEmail: self.userEmail!, withPrayerTitle: self.prayer!.title)
            LocalFirebaseData.started += 1
            self.alreadySaved = 1
        }
    }
    
    func downloadAndSetUpAudio(prayer: PrayerItem) {
        let destinationFileURL = Utilities.urlInDocumentsDirectory(forPath: prayer.audioURLPath)
        guard !FileManager.default.fileExists(atPath: destinationFileURL.path) else {
            print("That file's audio has already been downloaded")
            self.set(isLoading: false)
            setupAudioPlayer(file: prayer)
            return
        }
        
        print("attempting to download: \(prayer.audioURLPath)...")
        self.set(isLoading: true)
        self.pathReference = Storage.storage().reference(withPath: prayer.audioURLPath)
        
        self.downloadTask = self.pathReference!.write(toFile: destinationFileURL) { (url, error) in
            if let error = error {
                print("error downloading file: \(error)")
            } else {
                print("downloaded \(prayer.audioURLPath)")
                self.setupAudioPlayer(file: prayer)
            }
        }
        
        self.downloadTask!.observe(.progress) { snapshot in
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
            
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL, fileTypeHint: AVFileType.mp3.rawValue) // TODO: only for iOS 11, for iOS 10 and below: player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3)
            
            print("Audio player was set up")
            self.set(isLoading: false)
            
            if readyToPlay == false {
                readyToPlay = true
            } else {
                self.playPause()
            }
            
            updateProgressControl(songCompleted: completionHandler)
            
            audioPlayer?.currentTime = Constants.pausedTime
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Functions - Progress Control
    
    // TODO: Doesn't update consistently at least on lock screen each second esp. when play / pausing
    
    private func updateProgressControl(songCompleted: @escaping (Bool) -> Void) {
        if audioPlayer != nil {
            controlTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
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
                    songCompleted(true)
                } else {
                    songCompleted(false)
                }
                
                self?.setUpLockScreenInfo()
            }
        } else {
            setupAudioPlayer(file: prayer)
            print("Audio player is nil")
            return
        }
    }
    
    lazy var completionHandler: (Bool) -> Void = {
        if $0 {
            self.controlTimer?.invalidate()
            self.audioPlayer!.pause()
            self.playPauseButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            self.performSegue(withIdentifier: "reflectSegue", sender: self)
            self.loadAndSaveCompletedPrayers()
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
    
    private func loadAndSaveCompletedPrayers() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "completedPrayers", byUserEmail: self.userEmail!) {results in
            self.completedPrayers = results.map(PrayerTracking.init)
            LocalFirebaseData.completed = self.completedPrayers.count
            
            if self.completedPrayers.count > 0 {
                var date: [Date] = []
                for completedPrayer in self.completedPrayers {
                    date.append(completedPrayer.dateStored)
                }
                LocalFirebaseData.mostRecentPrayerDate = date.sorted()[date.count - 1]
            }
            
            LocalFirebaseData.completed += 1
            LocalFirebaseData.completedPrayers.append(self.prayer!.title) 
            
            self.updateMyStats()
            FirebaseUtilities.saveCompletedPrayer(byUserEmail: self.userEmail!, withPrayerTitle: self.prayer!.title)
        }
    }
    
    private func updateOnlyTimeStat() {
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUserEmail: self.userEmail!) { results in
            print("Results: \(results)")
            if results == [] {
                LocalFirebaseData.timeTracker = self.addedTimeTracker
                self.streak = 1
                LocalFirebaseData.streak = self.streak
                FirebaseUtilities.saveStats(byUserEmail: self.userEmail!, withTimeInPrayer: self.addedTimeTracker, withStreak: self.streak)
                
                
            } else {
                self.stats = results.map(StatsItem.init)[0]
                if let stats = self.stats {
                    stats.timeInPrayer += self.addedTimeTracker
                    LocalFirebaseData.timeTracker = stats.timeInPrayer
                    
                    LocalFirebaseData.streak = stats.streak
                    
                    FirebaseUtilities.updateStats(withDocID: stats.docID!, byUserEmail: self.userEmail!, withTimeInPrayer: stats.timeInPrayer, withStreak: stats.streak)
                } else {
                    print("Error: stats is nil")
                }
            }
        }
    }
    
    
    private func updateMyStats() {
        
        FirebaseUtilities.loadAllDocumentsFromUser(ofType: "stats", byUserEmail: self.userEmail!) { results in
            print("Results: \(results)")
            if results == [] {
                LocalFirebaseData.timeTracker = self.addedTimeTracker
                self.streak = 1
                LocalFirebaseData.streak = self.streak
                FirebaseUtilities.saveStats(byUserEmail: self.userEmail!, withTimeInPrayer: self.addedTimeTracker, withStreak: self.streak)
                
                
            } else {
                self.stats = results.map(StatsItem.init)[0]
                if let stats = self.stats {
                    stats.timeInPrayer += self.addedTimeTracker
                    LocalFirebaseData.timeTracker = stats.timeInPrayer
                    
                    // Update streak
                    let calendar = Calendar.current
                    let isNextDay = calendar.isDateInYesterday(LocalFirebaseData.mostRecentPrayerDate)
                    let isToday = calendar.isDateInToday(LocalFirebaseData.mostRecentPrayerDate)
                    
                    if isNextDay == true {
                        stats.streak += 1
                    } else {
                        if isToday == false {
                            stats.streak = 1
                        }
                    }
                    
                    LocalFirebaseData.streak = stats.streak
                    
                    FirebaseUtilities.updateStats(withDocID: stats.docID!, byUserEmail: self.userEmail!, withTimeInPrayer: stats.timeInPrayer, withStreak: stats.streak)
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
        hud.interactionType = .blockNoTouches
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
        self.timeLabel.isHidden = shouldHide
        self.nowPrayingLabel.isHidden = shouldHide
        self.nowPrayingTitleLabel.isHidden = shouldHide
    }
    
    // MARK: - Navigation
    // Unwind
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let ReflectViewController = destinationViewController as? ReflectViewController {
            let prayerTitle = "\(self.prayer!.title) - \(self.prayer!.description)"
            ReflectViewController.prayerTitle = prayerTitle
            Constants.pausedTime = 0.00
        } else if let destination = segue.destination as? UITabBarController, let prayNow = destination.viewControllers?.first as? PrayNowViewController, let prayer = sender as? PrayerItem {
            prayNow.prayer = prayer
            Constants.pausedTime = audioPlayer!.currentTime
        }
    }
    
    // MARK: - Design
    
    private func setUpProgressControlUI() {
        let image = #imageLiteral(resourceName: "thumbIcon")
        let newWidth = 3
        let newHeight = 6
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let thumbImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        progressControlOutlet.setThumbImage(thumbImage, for: .normal)
        
        progressControlOutlet.transform = progressControlOutlet.transform.scaledBy(x: 1, y: 2)
        progressControlOutlet.tintColor = UIColor(named: "fadedPink")
    }
}
