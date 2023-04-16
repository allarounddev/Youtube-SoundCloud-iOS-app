//
//  YoutubePlayerDelegate.swift
//  Streamini
//

import Foundation
import UIKit

class YoutubePlayerDelegate: NSObject, YouTubePlayerDelegate{
    
    var isRecent: Bool
    var replayView: ReplayView
    
    init(isRecent: Bool, replayView: ReplayView) {
        self.isRecent   = isRecent
        self.replayView = replayView
        super.init()
    }
    
    func streamDidLoad() {
        if isRecent {
            replayView.show()
        }
    }
    
    func streamDidFinish() {
        if isRecent {
            replayView.streamEnd()
        }
    }
    
    func streamDidFailedLoad() {
        UIAlertView.failedJoinStreamAlert().show()
    }

}
