//
//  NotificationsDelegate.swift
//  Streamini
//
//  Created by Vasily Evreinov on 28/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class NotificationsDelegate: NSObject, UIAlertViewDelegate {
    var streamId: UInt?
    
    func streamSuccess(_ stream: Stream) {
        
        // Post notifications to current controllers
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "Close/Leave"), object: nil))

        // Dismiss all view controllers behind MainViewController
        let root = UIApplication.shared.delegate!.window!?.rootViewController as! UINavigationController
        
        if root.topViewController!.presentedViewController != nil {
            root.topViewController!.presentedViewController!.dismiss(animated: true, completion: nil)
        }
        
        // Load join controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let joinNavController = storyboard.instantiateViewController(withIdentifier: "JoinStreamNavigationControllerId") as! UINavigationController
        let joinController = joinNavController.viewControllers[0] as! JoinStreamViewController

        
        // Setup joinController
        joinController.stream   = stream
        joinController.isRecent = (stream.ended != nil)
        
        // Show JoinController
        root.present(joinNavController, animated: true, completion: nil)
    }
    
    func streamFailure(_ error: NSError) {
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            if let id = streamId {
                StreamConnector().get(id, success: streamSuccess, failure: streamFailure)
            }
        }
    }
 
}
