//
//  YouTubePlayer.swift
//  Streamini
//
//  Created by developer on 6/6/17.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit
//import youtube_ios_player_helper


protocol YouTubePlayerDelegate {
    func streamDidLoad()
    func streamDidFinish()
}


class YouTubePlayer : NSObject, YTPlayerViewDelegate{
    
    var view: YTPlayerView?
    var indicator: UIActivityIndicatorView?
    var isRecent = false
    var delegate: YouTubePlayerDelegate?
    var replayView: ReplayView

    init(stream: Stream, isRecent: Bool, view: YTPlayerView, indicator: UIActivityIndicatorView, replayView: ReplayView) {
        
        self.view       = view
        self.indicator  = indicator
        self.isRecent   = isRecent
        self.replayView = replayView
        super.init()

        let url = streamURL(stream)
        NotificationCenter.default.addObserver(self, selector: #selector(StreamPlayer.streamDidFinish(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

        indicator.startAnimating()
        
        self.view?.load(withVideoId: url, playerVars: ["playsinline": 1, "showinfo" : 0, "rel" : 0, "modestbranding" : 1, "controls" : 1, "origin" : "https://www.youtube.com"])
        self.replayView.show()
    }
    deinit {
        reset()
    }

    func reset(){
        
    }
    
    func play() {
        indicator?.stopAnimating()
        self.view?.playVideo()
    }
    
    func stop() {
        self.view?.stopVideo()
    }


    func streamDidFinish(_ notification: Notification) {
        
        if let del = delegate {
            del.streamDidFinish()
        }
    }

    fileprivate func streamURL(_ stream: Stream) -> String {
        
        let url: String

        if isRecent {
            print(stream.extras)
            // for test
            url = stream.extras
        } else {
            url = stream.extras
        }
        return url
    }
}
