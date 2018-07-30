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
    var guideSelected: User.Guide = User.Guide.Francis
    var guidePlaying: User.Guide?
    var francisSampleAudioURL = "audio/Samples - F.mp3"
    var abbySampleAudioURL = "audio/Samples - A.mp3"
    
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
    @IBAction func nextButton(_ sender: Any) {
        RealmUtilities.updateGuide(withGuide: guideSelected) {
            performSegue(withIdentifier: "guideSelectedSegue", sender: self)
            FirebaseUtilities.syncUserData { }
        }
    }
    
    @IBAction func francisButton(_ sender: UIButton) {
        francisButton.isSelected = !francisButton.isSelected
        abbyButton.isSelected = !abbyButton.isSelected
        guideSelected = User.Guide.Francis
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButton.isSelected = !abbyButton.isSelected
        francisButton.isSelected = !francisButton.isSelected
        guideSelected = User.Guide.Abby
    }
    
    @IBAction func francisPlaySample(_ sender: UIButton) {
        if !firstPlay {
            audioPlayer?.stop()
        }
        downloadAudio(guide: User.Guide.Francis, audioURL: self.francisSampleAudioURL, setLoading: { isLoading in
            self.set(isLoading: isLoading)
        }, completionBlock: { guide, audioURL in
            self.setupAudioPlayer(guide: User.Guide.Francis, audioURL: self.francisSampleAudioURL, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: {
            }, playPause: { guide in
                self.playToggle(guide: User.Guide.Francis)
            })
        })
        firstPlay = false
    }
    
    @IBAction func abbyPlaySample(_ sender: UIButton) {
        if !firstPlay {
            audioPlayer?.stop()
        }
        
        downloadAudio(guide: User.Guide.Abby, audioURL: abbySampleAudioURL, setLoading: { isLoading in
            self.set(isLoading: isLoading)
        }, completionBlock: { guide, audioURL in
            self.setupAudioPlayer(guide: User.Guide.Abby, audioURL: self.abbySampleAudioURL, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: {
            }, playPause: { guide in
                self.playToggle(guide: User.Guide.Abby)
            })
        })
        firstPlay = false
    }
    
    // MARK: - Functions - Play toggle
    
    private func set(isLoading: Bool) {
        if isLoading {
            showDownloadingHudBlockTouches()
        } else {
            dismissHud()
        }
    }
    
    private func playToggle(guide: User.Guide) {
        switch guide {
        case .Francis:
            if isPlaying, guidePlaying == User.Guide.Abby {
                abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                audioPlayer?.stop()
                isPlaying = false
                downloadAudio(guide: User.Guide.Francis, audioURL: francisSampleAudioURL, setLoading: { isLoading in
                    self.set(isLoading: isLoading)
                }, completionBlock: { guide, audioURL in
                    self.setupAudioPlayer(guide: User.Guide.Abby, audioURL: self.francisSampleAudioURL, setLoading: { isLoading in
                        self.set(isLoading: isLoading)
                    }, updateProgress: {
                    }, playPause: { guide in
                        self.playToggle(guide: User.Guide.Francis)
                    })
                })
            } else {
                if !isPlaying {
                    francisPlaySampleButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
                    audioPlayer?.play()
                    isPlaying = true
                    guidePlaying = User.Guide.Francis
                } else {
                    francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                    audioPlayer?.pause()
                    isPlaying = false
                }
            }
        case .Abby:
            if isPlaying, guidePlaying == User.Guide.Francis {
                francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                audioPlayer?.stop()
                isPlaying = false
                downloadAudio(guide: User.Guide.Abby, audioURL: abbySampleAudioURL, setLoading: { isLoading in
                    self.set(isLoading: isLoading)
                }, completionBlock: { guide, audioURL in
                    self.setupAudioPlayer(guide: User.Guide.Abby, audioURL: self.abbySampleAudioURL, setLoading: { isLoading in
                        self.set(isLoading: isLoading)
                    }, updateProgress: {
                    }, playPause: { guide in
                        self.playToggle(guide: User.Guide.Abby)
                    })
                })
            } else {
                if !isPlaying {
                    abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
                    audioPlayer?.play()
                    isPlaying = true
                    guidePlaying = User.Guide.Abby
                } else {
                    abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
                    audioPlayer?.pause()
                    isPlaying = false
                }
            }
        }
    }
    
    // MARK: - Functions - Check progress
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.audioPlayer?.stop()
        self.francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        self.abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        isPlaying = false
    }
}
