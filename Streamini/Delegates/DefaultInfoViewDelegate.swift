//
//  InfoViewDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class DefaultInfoViewDelegate: NSObject, InfoViewDelegate {
    var closeButton: UIButton
    var infoButton: UIButton
    var rotateButton: UIButton?
    var stream: Stream?
    
    init(close: UIButton, info: UIButton, rotate: UIButton?) {
        closeButton     = close
        infoButton      = info
        rotateButton    = rotate
        super.init()
    }
    
    func infoViewWillBeShown(_ infoView: InfoView) {
        infoView.update(stream!)
        closeButton.isHidden   = true
        infoButton.isHidden    = true
        
        if let rotate = rotateButton {
            rotate.isHidden  = true
        }
    }
    
    func infoViewWillBeHidden(_ infoView: InfoView) {
        closeButton.isHidden   = false
        infoButton.isHidden    = false

        if let rotate = rotateButton {
            rotate.isHidden  = false
        }
    }
    
    func reportButtonPressed() { }
    func shareButtonPressed() { }
}

class JoinInfoViewDelegate: DefaultInfoViewDelegate {
    var alertViewDelegate: UIAlertViewDelegate
    var actionSheetDelegate: UIActionSheetDelegate
    var actionSheetView: UIView
    
    init(close: UIButton, info: UIButton, alertViewDelegate: UIAlertViewDelegate, actionSheetDelegate: UIActionSheetDelegate, actionSheetView: UIView) {
        self.alertViewDelegate      = alertViewDelegate
        self.actionSheetDelegate    = actionSheetDelegate
        self.actionSheetView        = actionSheetView
        super.init(close: close, info: info, rotate: nil)
    }
    
    override func reportButtonPressed() {
        UIAlertView.reportConfirmationAlert(stream!.title, delegate: alertViewDelegate).show()
    }
    
    override func shareButtonPressed() {
        UIActionSheet.shareActionSheet(actionSheetDelegate).show(in: actionSheetView)
    }
    
}
