//
//  StreamPlayerDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class DefaultStreamPlayerDelegate: NSObject, StreamPlayerDelegate {
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
