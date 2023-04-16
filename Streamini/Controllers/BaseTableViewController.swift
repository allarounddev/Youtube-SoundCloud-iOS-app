//
//  BaseTableViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 02/09/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func handleError(_ error: NSError) {
        if let userInfo = error.userInfo as? [NSObject: NSObject] {
            // modify and assign values as necessary
            if userInfo["code" as NSObject] as? UInt == kLoginExpiredCode {
                
                // Open login screen
                let root = UIApplication.shared.delegate!.window!?.rootViewController as! UINavigationController
                
                if root.topViewController!.presentedViewController != nil {
                    root.topViewController!.presentedViewController!.dismiss(animated: true, completion: nil)
                }
                
                let controllers = root.viewControllers.filter({ ($0 is LoginViewController) })
                root.setViewControllers(controllers, animated: true)
                
                // Show alert
                let message = userInfo[NSLocalizedDescriptionKey as NSObject] as! String
                let alertView = UIAlertView.notAuthorizedAlert(message)
                alertView.show()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
