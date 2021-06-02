//
//  AudioManager.swift
//  WWDC2021
//
//  Created by Alan Yan on 2021-04-08.
//

import AVFoundation
import MediaPlayer

protocol AudioManagerDelegate: class {
    func trackDidFinish()
}
public class AudioManager: NSObject, AVAudioPlayerDelegate {
    private var mode: DanceController.Mode
    private var builtInAudioPlayer: AVAudioPlayer?
    private var appleMusicAudioPlayer: MPMusicPlayerController {
        return MPMusicPlayerController.applicationMusicPlayer
    }
    
    var currentTime: TimeInterval {
        switch mode.track.type {
        case .builtIn:
            return builtInAudioPlayer?.currentTime ?? 0
        case .musicLibrary:
            return appleMusicAudioPlayer.currentPlaybackTime
        }
    }
    
    var speed: Float {
        get {
            switch mode.track.type {
            case .builtIn:
                return builtInAudioPlayer?.rate ?? 0
            case .musicLibrary:
                return appleMusicAudioPlayer.currentPlaybackRate
            }
        }
        set {
            switch mode.track.type {
            case .builtIn:
                builtInAudioPlayer?.enableRate = true
                builtInAudioPlayer?.rate = newValue
            case .musicLibrary:
                appleMusicAudioPlayer.currentPlaybackRate = newValue
            }
        }
    }
    var isPlaying: Bool {
        switch mode.track.type {
        case .builtIn:
            return builtInAudioPlayer?.isPlaying ?? false
        case .musicLibrary:
            return appleMusicAudioPlayer.playbackState == .playing
        }
    }
    
    weak var delegate: AudioManagerDelegate?
    
    init(mode: DanceController.Mode) {
        self.mode = mode
    }
    
    
    func setup() {
        if let mediaItem = mode.track.url {
            appleMusicAudioPlayer.repeatMode = .none
            appleMusicAudioPlayer.shuffleMode = .off
            appleMusicAudioPlayer.stop()
            appleMusicAudioPlayer.setQueue(with: MPMediaItemCollection(items: [mediaItem]))
            appleMusicAudioPlayer.repeatMode = .none
            appleMusicAudioPlayer.shuffleMode = .off
            appleMusicAudioPlayer.prepareToPlay()
            appleMusicAudioPlayer.currentPlaybackRate = Float(mode.speed)
            NotificationCenter.default.addObserver(self, selector: #selector(finish), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: MPMusicPlayerController.applicationMusicPlayer)
        } else {
            do {
                let path = Bundle.main.path(forResource: "\(mode.track.fileName).mp3", ofType:nil)!
                let url = URL(fileURLWithPath: path)
                builtInAudioPlayer = try AVAudioPlayer(contentsOf: url)
                builtInAudioPlayer?.enableRate = true
                builtInAudioPlayer?.delegate = self
                builtInAudioPlayer?.rate = Float(mode.speed)
            } catch {
            }
        }
    }
    
    func setTime(_ time: TimeInterval) {
        switch mode.track.type {
        case .builtIn:
            builtInAudioPlayer?.currentTime = time
        case .musicLibrary:
            appleMusicAudioPlayer.currentPlaybackTime = time
        }
    }
    func play() {
        switch mode.track.type {
        case .builtIn:
            guard let audioPlayer = builtInAudioPlayer else { return }
            audioPlayer.play()
        case .musicLibrary:
            appleMusicAudioPlayer.play()
            appleMusicAudioPlayer.beginGeneratingPlaybackNotifications()
        }
    }
    
    func pause() {
        switch mode.track.type {
        case .builtIn:
            guard let audioPlayer = builtInAudioPlayer else { return }
            audioPlayer.pause()
        case .musicLibrary:
            appleMusicAudioPlayer.pause()
        }
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finish()
    }
    @objc private func finish() {
        if mode.track.type == .musicLibrary && !(appleMusicAudioPlayer.playbackState == .paused
            && appleMusicAudioPlayer.currentPlaybackTime == 0) { return }
        
        delegate?.trackDidFinish()
    }
}
