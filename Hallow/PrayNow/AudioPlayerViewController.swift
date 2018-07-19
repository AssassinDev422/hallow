//
//  AudioPlayerViewController.swift
//  Hallow
//
//  Created by Alex Jones on 5/10/18.
//  Copyright © 2018 Hallow. All rights reserved.
//

//FIXME - maybe: Day 1 - 5 mins after loading it went straight to journal
//TODO: Need to update constants.guide.francis eventually

import UIKit
import AVFoundation
import FirebaseStorage
import JGProgressHUD
import FirebaseFirestore
import Firebase
import MediaPlayer

class AudioPlayerViewController: AudioController {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nowPrayingLabel: UILabel!
    @IBOutlet weak var nowPrayingTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    var prayer: PrayerItem?
    
    var userEmail: String?
    
    var controlTimer: Timer?
    
    var alreadySaved = 0
    
    var addedTimeTracker = 0.00

    var streak: Int = 0
    var stats: StatsItem?
    
    var completedPrayers: [PrayerTracking] = []
    
    var nowPlayingInfo = [String : Any]()
    
    // MARK: - Life cycle
   
    override func viewDidLoad() {
        hideOutlets(shouldHide: true)
        setUpProgressControlUI(progressSlider: progressSlider)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let prayer = prayer {
            downloadAudio(guide: Constants.Guide.Francis, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                    self.set(isLoading: isLoading)
                }, completionBlock: { guide, audioURL in
                    self.setupAudioPlayer(guide: Constants.Guide.Francis, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                        self.set(isLoading: isLoading)
                    }, updateProgress: {
                        self.updateProgressControl()
                    }, playPause: { guide in
                        self.playPause()
                    })
                })
            nowPrayingTitleLabel.text = self.prayer?.description
        }
        self.userEmail = LocalFirebaseData.userEmail
        alreadySaved = 0
        addedTimeTracker = 0.0
        ReachabilityManager.shared.addListener(listener: self)
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget(self, action: #selector(playPause))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTime = Date(timeIntervalSinceNow: 0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        controlTimer?.invalidate()
        audioPlayer?.currentTime = 0
        audioPlayer?.currentTime = 0
        audioPlayer?.stop()
        progressSlider.setValue(Float(0.0), animated: false)
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
        exitButton.setTitleColor(UIColor(named: "beige"), for: .normal)
        
        if let audioPlayer = audioPlayer {
            let timeLeft = audioPlayer.duration - audioPlayer.currentTime
            if timeLeft < 10.0 {
                self.controlTimer?.invalidate()
                self.audioPlayer!.pause()
                self.playPauseButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                self.performSegue(withIdentifier: "reflectSegue", sender: self)
                self.loadAndSaveCompletedPrayers()
            } else {
                Constants.pausedTime = audioPlayer.currentTime
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        exitButton.setTitleColor(UIColor(named: "fadedPink"), for: .normal)
    }
    
    // MARK: - Functions
    
    private func setUpLockScreenInfo() {
        nowPlayingInfo[MPMediaItemPropertyTitle] = "\(prayer?.title ?? "") - \(prayer?.description ?? "")"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioPlayer?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] =  self.audioPlayer?.duration
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc private func playPause() {
        Constants.hasStartedListening = true
        guard let audioPlayer = audioPlayer else {
            guard let prayer = prayer else {
                print("prayer not set")
                return
            }
            self.setupAudioPlayer(guide: Constants.Guide.Francis, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: {
                self.updateProgressControl()
            }, playPause: { guide in
                self.playPause()
            })
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
            FirebaseUtilities.saveStartedPrayer(byUserEmail: LocalFirebaseData.userEmail, withPrayerTitle: self.prayer!.title)
            LocalFirebaseData.started += 1
            self.alreadySaved = 1
        }
    }
    
    // MARK: - Functions - Progress Control
    
    // FIXME: Doesn't update consistently at least on lock screen each second esp. when play / pausing
    
    private func updateProgressControl() {
        if audioPlayer != nil {
            controlTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
                let percentComplete = self!.audioPlayer!.currentTime / self!.audioPlayer!.duration
                self?.progressSlider.setValue(Float(percentComplete), animated: true)
                
                let time = self!.audioPlayer!.currentTime
                let minutes = Int(time) / 60 % 60
                let seconds = Int(time) % 60
                self?.timeLabel.text = String(format:"%01i:%02i", minutes, seconds)
                
                self?.timeLabel.frame.origin.x = 5 + CGFloat(percentComplete) * (self?.progressSlider.frame.width)!
                
                self?.setUpLockScreenInfo()
            }
        } else {
            guard let prayer = prayer else {
                print("Prayer not set")
                return
            }
            self.setupAudioPlayer(guide: Constants.Guide.Francis, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: {
                self.updateProgressControl()
            }, playPause: { guide in
                self.playPause()
            })
            print("Audio player is nil")
            return
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.controlTimer?.invalidate()
        self.audioPlayer!.pause()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        self.performSegue(withIdentifier: "reflectSegue", sender: self)
        self.loadAndSaveCompletedPrayers()
    }
    
    private func sliderUpdatedTime() {
        if let audioPlayer = audioPlayer {
            let percentComplete = progressSlider.value
            audioPlayer.currentTime = TimeInterval(percentComplete * Float(audioPlayer.duration))
        } else {
            guard let prayer = prayer else {
                print("Prayer not set")
                return
            }
            self.setupAudioPlayer(guide: Constants.Guide.Francis, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: {
                self.updateProgressControl()
            }, playPause: { guide in
                self.playPause()
            })
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
                   
                    print("Original time: \(stats.timeInPrayer)")
                    
                    self.addedTimeTracker = Date().timeIntervalSince(self.startTime)
                    print("Start time: \(self.startTime) - Added time: \(self.addedTimeTracker)")
                    
                    stats.timeInPrayer += self.addedTimeTracker
                    LocalFirebaseData.timeTracker = stats.timeInPrayer
                    
                    LocalFirebaseData.streak = stats.streak
                    
                    FirebaseUtilities.updateStats(withDocID: stats.docID!, byUserEmail: self.userEmail!, withTimeInPrayer: stats.timeInPrayer, withStreak: stats.streak)
                    print("Delta time: \(self.addedTimeTracker)")
                    print("Updated Time: \(stats.timeInPrayer)")
                    
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
                    
                    print("Original time: \(stats.timeInPrayer)")
                    
                    self.addedTimeTracker = Date().timeIntervalSince(self.startTime)
                    print("Start time: \(self.startTime) - Added time: \(self.addedTimeTracker)")
                    
                    stats.timeInPrayer += self.addedTimeTracker
                    LocalFirebaseData.timeTracker = stats.timeInPrayer
                    
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
                    
                    print("Delta time: \(self.addedTimeTracker)")
                    print("Updated Time: \(stats.timeInPrayer)")
                    
                    FirebaseUtilities.updateStats(withDocID: stats.docID!, byUserEmail: self.userEmail!, withTimeInPrayer: stats.timeInPrayer, withStreak: stats.streak)
                } else {
                    print("Error: stats is nil")
                }
            }
        }
    }
    
    // MARK: - Functions - Set loading
    
    private func set(isLoading: Bool) {
        hideOutlets(shouldHide: isLoading)
        if isLoading {
            self.showDownloadingHud()
        } else {
            self.dismissHud()
        }
    }
    
    private func hideOutlets(shouldHide: Bool) {
        self.playPauseButton.isHidden = shouldHide
        self.progressSlider.isHidden = shouldHide
        self.timeLabel.isHidden = shouldHide
        self.nowPrayingLabel.isHidden = shouldHide
        self.nowPrayingTitleLabel.isHidden = shouldHide
    }
    
    // MARK: - Navigation
    // Unwind
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
    }
    
    // Prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let ReflectViewController = destinationViewController as? ReflectViewController {
            let prayerTitle = "\(self.prayer!.title) - \(self.prayer!.description)"
            ReflectViewController.prayerTitle = prayerTitle
            Constants.pausedTime = 0.00
        }
    }
    
}
