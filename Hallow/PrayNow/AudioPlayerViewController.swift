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
import RealmSwift

class AudioPlayerViewController: AudioController {

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nowPrayingLabel: UILabel!
    @IBOutlet weak var nowPrayingTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    var prayer: PrayerItem?
    var controlTimer: Timer?
    var addedTimeTracker = 0.00
    var nowPlayingInfo = [String : Any]()
    var user = User()
    var guide: User.Guide = User.Guide.Francis
    
    // MARK: - Life cycle
   
    override func viewDidLoad() {
        hideOutlets(shouldHide: true)
        setUpProgressControlUI(progressSlider: progressSlider)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            let realm = try Realm() 
            guard let realmUser = realm.objects(User.self).first else {
                print("REALM: Error in will appear of audioplayer")
                return
            }
            user = realmUser
        } catch {
            print("REALM: Error in will appear of audioplayer")
        }
        setGuide()
        if let prayer = prayer {
            downloadAudio(guide: guide, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                    self.set(isLoading: isLoading)
                }, completionBlock: { guide, audioURL in
                    self.setGuide()
                    self.setupAudioPlayer(guide: guide, audioURL: prayer.audioURLPath, setLoading: { isLoading in
                        self.set(isLoading: isLoading)
                    }, updateProgress: {
                        self.updateProgressControl()
                    }, playPause: { guide in
                        self.playPause()
                    })
                })
            nowPrayingTitleLabel.text = self.prayer?.desc
        }
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
        audioPlayer?.stop()
        progressSlider.setValue(Float(0.0), animated: false)
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
            self.dismiss(animated: true, completion: nil)
        }
        exitButton.setTitleColor(UIColor(named: "beige"), for: .normal)
        if let audioPlayer = audioPlayer {
            let timeLeft = audioPlayer.duration - audioPlayer.currentTime
            if timeLeft < 10.0 {
                audioCompleted()
                self.performSegue(withIdentifier: "reflectSegue", sender: self)
            } else {
                RealmUtilities.prayerExited(withStartTime: startTime)
                RealmUtilities.setCurrentAudioTime(withCurrentTime: audioPlayer.currentTime)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func exitButtonPressed(_ sender: Any) {
        exitButton.setTitleColor(UIColor(named: "fadedPink"), for: .normal)
    }
    
    // MARK: - Functions
    
    private func setUpLockScreenInfo() {
        nowPlayingInfo[MPMediaItemPropertyTitle] = "\(prayer?.title ?? "") - \(prayer?.desc ?? "")"
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.audioPlayer?.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] =  self.audioPlayer?.duration
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc private func playPause() {
        guard let audioPlayer = audioPlayer else {
            guard let prayer = prayer else {
                print("prayer not set")
                return
            }
            self.setupAudioPlayer(guide: guide, audioURL: prayer.audioURLPath, setLoading: { isLoading in
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
    }
    
    // MARK: - Functions - Progress Control
    // FIXME: Doesn't update consistently at least on lock screen each second esp. when play / pausing
    
    private func updateProgressControl() {
        if audioPlayer != nil {
            controlTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { [weak self] timer in
                guard let audioPlayer = self?.audioPlayer else {
                    print("Error in updateProgressControl")
                    return
                }
                let percentComplete = audioPlayer.currentTime / audioPlayer.duration
                self?.progressSlider.setValue(Float(percentComplete), animated: true)
                let time = audioPlayer.currentTime
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
            self.setupAudioPlayer(guide: guide, audioURL: prayer.audioURLPath, setLoading: { isLoading in
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
        audioCompleted()
        self.performSegue(withIdentifier: "reflectSegue", sender: self)
    }
    
    private func audioCompleted() {
        self.controlTimer?.invalidate()
        guard let audioPlayer = audioPlayer, let prayer = prayer else {
            print("Error in audioCompleted")
            return
        }
        audioPlayer.pause()
        self.playPauseButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        RealmUtilities.prayerCompleted(completedPrayerTitle: prayer.title, withStartTime: startTime)
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
            self.setupAudioPlayer(guide: guide, audioURL: prayer.audioURLPath, setLoading: { isLoading in
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
    
    private func setGuide() { //TODO: Likely not needed
        if user.guide == User.Guide.Francis {
            guide = User.Guide.Francis
        } else {
            guide = User.Guide.Abby
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let ReflectViewController = destinationViewController as? ReflectViewController, let prayer = self.prayer {
            let prayerTitle = "\(prayer.title) - \(prayer.desc)"
            ReflectViewController.prayerTitle = prayerTitle
            RealmUtilities.setCurrentAudioTime(withCurrentTime: 0.00)
        }
    }
}
