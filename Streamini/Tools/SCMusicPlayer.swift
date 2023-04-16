//
//  SCMusicPlayer.swift
//  Streamini
//
//  Created by developer on 6/29/17.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

protocol SCMusicPlayerViewDelegate {
    func streamDidLoad()
    func streamDidFinish()
}


class SCMusicPlayer : NSObject {
    
    var player: AVPlayer?
    var playerViewController: AVPlayerViewController?
    var view: UIView?
    var indicator: UIActivityIndicatorView?
    var isRecent = false
    var delegate: SCMusicPlayerViewDelegate?
    var replayView: ReplayView
    var url: URL?
    init(stream: Stream, isRecent: Bool, view: UIView, indicator: UIActivityIndicatorView, replayView: ReplayView) {
        
        self.view       = view
        self.indicator  = indicator
        self.isRecent   = isRecent
        self.replayView = replayView
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(StreamPlayer.streamDidFinish(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        indicator.startAnimating()
        
        print("selected")
        url = streamURL(stream)
        player = AVPlayer(url: url!)
        self.replayView.show()
    }
    deinit {
        reset()
    }
    
    func reset(){
        
    }
    
    func play() {
        indicator?.stopAnimating()
        if (player!.status == AVPlayer.Status.readyToPlay) {
            player!.seek(to: CMTimeMake(value: 0, timescale: player!.currentTime().timescale), completionHandler: { (finished) -> Void in
//                self.playerLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                self.player!.play()
            })
        }
    }
    
    func stop() {
        player?.pause()
    }
    
    
    func streamDidFinish(_ notification: Notification) {
        
        if let del = delegate {
            del.streamDidFinish()
        }
    }
    
    fileprivate func streamURL(_ stream: Stream) -> URL {
        
        let url: String
        
        if isRecent {
            let string = stream.extras
            print(stream.extras)
            if let range = string.range(of: "/stream") {
                let firstPart = string[string.startIndex..<range.lowerBound]
                
                print(firstPart)
                url = "\(firstPart)/stream?client_id=\(Soundcloud.clientIdentifier!)"
            } else {
                url = "\(stream.extras)/stream?client_id=\(Soundcloud.clientIdentifier!)"
            }
            print(url)
        } else {
            url = stream.extras
        }
        return URL(string: url)!
    }
}
