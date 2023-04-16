//
//  StreamPlayer.swift
//  Streamini
//
//  Created by Vasily Evreinov on 14/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol StreamPlayerDelegate {
    func streamDidLoad()
    func streamDidFinish()
}

class StreamPlayer: NSObject {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var view: UIView?
    var indicator: UIActivityIndicatorView?
    var isRecent = false
    var delegate: StreamPlayerDelegate?
    
    // MARK: - Initialization
    
    init(stream: Stream, isRecent: Bool, view: UIView, indicator: UIActivityIndicatorView) {
        super.init()
        self.view       = view
        self.indicator  = indicator
        self.isRecent   = isRecent
        
        let url = streamURL(stream)
        self.player = AVPlayer(url: url) as? AVPlayer
        player!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamPlayer.streamDidFinish(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)        
        
        self.playerLayer = AVPlayerLayer(player: player!)
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerLayer!.addObserver(self, forKeyPath: "readyForDisplay", options: NSKeyValueObservingOptions(), context: nil)
        
        indicator.startAnimating()
        
        var asError: NSError?
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.mixWithOthers)
        } catch let error as NSError {
            asError = error
        }
        do {
            try audioSession.setMode(AVAudioSession.Mode.videoRecording)
        } catch let error as NSError {
            asError = error
        }
        
        do {
            try audioSession.setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
        } catch let error as NSError {
            asError = error
        }
        NotificationCenter.default.addObserver(self, selector: #selector(StreamPlayer.playInterrupt(_:)), name: AVAudioSession.interruptionNotification, object: audioSession)
    }
    
    deinit {
        reset()
    }
    
    func reset() {
        if let p = player, let pl = playerLayer {
            NotificationCenter.default.removeObserver(self)
            
            player!.removeObserver(self, forKeyPath: "status")
            playerLayer!.removeObserver(self, forKeyPath: "readyForDisplay")
            
            player = nil
            playerLayer!.player = nil
            playerLayer = nil
        }
    }
    
    // MARK: - Play/Stop methods
    
    func play() {
        if (player!.status == AVPlayer.Status.readyToPlay) {
            player!.seek(to: CMTimeMake(value: 0, timescale: player!.currentTime().timescale), completionHandler: { (finished) -> Void in
                self.playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                self.player!.play()
            })
        }
    }
        
    func stop() {
        if let p = player {
            player!.pause()
        }
    }
    
    // MARK: - Notifications and observers
    
    @objc func streamDidFinish(_ notification: Notification) {
        playerLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        if let del = delegate {
            del.streamDidFinish()
        }
    }

    // MARK: - Observers 
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if (player!.status == AVPlayer.Status.readyToPlay) {
                player!.play()
            }

        }
        
        if keyPath == "readyForDisplay" {
            if playerLayer!.isReadyForDisplay {
                indicator!.stopAnimating()
                playerLayer!.frame = view!.frame
                view!.layer.addSublayer(playerLayer!)
                
                if isRecent {
                    player!.pause()
                }
                
                if let del = self.delegate {
                    del.streamDidLoad()
                }
            }
        }
    }
    
    @objc func playInterrupt(_ notification: Notification) {
        
        if notification.name == AVAudioSession.interruptionNotification && notification.userInfo != nil {
            var intValue: UInt = 0
            (notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSValue).getValue(&intValue)
            
            if let type = AVAudioSession.InterruptionType(rawValue: intValue) {
                
                switch type {
                    
                case .began:
                    // interruption began
                    // NOTE: the pause function saves play state
                    self.player!.play()
                    
                case .ended:
                    // interruption ended
                    self.player!.play()

                }
            }
        }
    }

    // MARK: - Private methods
    
    fileprivate func streamURL(_ stream: Stream) -> URL {
        let (host, port, application, _, _) = Config.shared.wowza()
        let streamName = "\(stream.streamHash)-\(stream.id)"
        let url: String
        let (accessKeyId, _, _, streamBucket, _) = Config.shared.amazon()
        if isRecent {
            url = accessKeyId == ""
                ? "http://\(host):\(port)/vod/_definist_/mp4:\(streamName).mp4/playlist.m3u8"
                : "http://\(host):\(port)/vods3/_definist_/mp4:amazons3/\(streamBucket)/\(streamName).mp4/playlist.m3u8"

        } else {
            url = "http://\(host):\(port)/\(application)/\(streamName)/playlist.m3u8"
        }
        return URL(string: url)!
    }
}
