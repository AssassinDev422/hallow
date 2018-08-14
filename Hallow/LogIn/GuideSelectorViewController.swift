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
    var guideSelected: User.Guide = User.Guide.francis
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
        audioPlayer?.currentTime = 0
        audioPlayer?.stop()
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
            self.performSegue(withIdentifier: "guideSelectedSegue", sender: self)
            FirebaseUtilities.syncUserData()
        }
    }
    
    @IBAction func francisButton(_ sender: UIButton) {
        francisButton.isSelected = !francisButton.isSelected
        abbyButton.isSelected = !abbyButton.isSelected
        guideSelected = User.Guide.francis
    }
    
    @IBAction func abbyButton(_ sender: UIButton) {
        abbyButton.isSelected = !abbyButton.isSelected
        francisButton.isSelected = !francisButton.isSelected
        guideSelected = User.Guide.abby
    }
    
    @IBAction func francisPlaySample(_ sender: UIButton) {
        if !firstPlay {
            audioPlayer?.stop()
        }
        downloadAudio(guide: User.Guide.francis, audioURL: francisSampleAudioURL, setLoading: { isLoading in
            set(isLoading: isLoading)
        }, completionBlock: { guide, audioURL in
            self.setupAudioPlayer(guide: User.Guide.francis, audioURL: self.francisSampleAudioURL, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: nil, playPause: { guide in
                self.playToggle(guideSelected: User.Guide.francis)
            })
        })
        firstPlay = false
    }
    
    @IBAction func abbyPlaySample(_ sender: UIButton) {
        if !firstPlay {
            audioPlayer?.stop()
        }
        
        downloadAudio(guide: User.Guide.abby, audioURL: abbySampleAudioURL, setLoading: { isLoading in
            set(isLoading: isLoading)
        }, completionBlock: { guide, audioURL in
            self.setupAudioPlayer(guide: User.Guide.abby, audioURL: self.abbySampleAudioURL, setLoading: { isLoading in
                self.set(isLoading: isLoading)
            }, updateProgress: {
            }, playPause: { guide in
                self.playToggle(guideSelected: User.Guide.abby)
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
    
    private func playToggle(guideSelected: User.Guide) {
        var otherGuide: User.Guide
        var selectedButton: UIButton
        var otherButton: UIButton
        var url: String
        switch guideSelected {
            case .francis:
                selectedButton = francisPlaySampleButton
                otherGuide = User.Guide.abby
                otherButton = abbyPlaySampleButton
                url = francisSampleAudioURL
            case .abby:
                selectedButton = abbyPlaySampleButton
                otherGuide = User.Guide.francis
                otherButton = francisPlaySampleButton
                url = abbySampleAudioURL
        }
        
        if isPlaying, guidePlaying == otherGuide {
            otherButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            audioPlayer?.stop()
            isPlaying = false
            downloadAudio(guide: guideSelected, audioURL: url, setLoading: { isLoading in
                set(isLoading: isLoading)
            }, completionBlock: { guide, audioURL in
                self.setupAudioPlayer(guide: guideSelected, audioURL: url, setLoading: { isLoading in
                    self.set(isLoading: isLoading)
                }, updateProgress: {
                }, playPause: { guide in
                    self.playToggle(guideSelected: guideSelected)
                })
            })
        } else {
            if !isPlaying {
                audioPlayer?.play()
                isPlaying = true
                guidePlaying = guideSelected
                selectedButton.setImage(#imageLiteral(resourceName: "pauseButtonImage"), for: .normal)
            } else {
                audioPlayer?.pause()
                isPlaying = false
                selectedButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
            }
        }
    }
    
    // MARK: - Functions - Check progress
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer?.stop()
        francisPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        abbyPlaySampleButton.setImage(#imageLiteral(resourceName: "playButtonImage"), for: .normal)
        isPlaying = false
    }
}
