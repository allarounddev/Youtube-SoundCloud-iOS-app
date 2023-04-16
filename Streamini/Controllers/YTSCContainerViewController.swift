//
//  YTSCContainerViewController.swift
//  Streamini
//
//  Created by developer on 10/12/17.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit


class YTSCContainerViewController: UIViewController {
    
    let kSegueIdentifierYouTube    = "embedYouTube"
    let kSegueIdentifierSoundCloud  = "embedSoundCloud"
    var currentSegueIdentifier  = "embedYouTube"

    var parentController: YTSCSearchViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegue(withIdentifier: kSegueIdentifierYouTube, sender: self)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let sid = segue.identifier {
//            let destinationController = segue.destination
//            
//            if sid == kSegueIdentifierYouTube {
////                (destinationController as! YoutubeSearchViewController).rootControllerDelegate = parentController!
//                parentController!.delegate = (destinationController as! YoutubeSearchViewController)
//                
//                if self.childViewControllers.count > 0 {
//                    swapFromViewController(childViewControllers[0] , toViewController: destinationController)
//                } else {
//                    self.addChildViewController(destinationController)
//                    destinationController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//                    self.view.addSubview(destinationController.view)
//                    segue.destination.didMove(toParentViewController: self)
//                }
//            } else if segue.identifier == kSegueIdentifierSoundCloud {
//                self.swapFromViewController(childViewControllers[0] , toViewController: destinationController)
//                
//            }
//        }
    }
    
    // MARK: - Helpers
    
    func swapFromViewController(_ fromViewController: UIViewController, toViewController: UIViewController) {
        toViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        fromViewController.willMove(toParent: nil)
        self.addChild(toViewController)
        self.transition(from: fromViewController, to: toViewController, duration: TimeInterval(1.0), options: UIView.AnimationOptions(), animations: nil) { (finished) -> Void in
            fromViewController.removeFromParent()
            toViewController.didMove(toParent: self)
        }
    }

    func swapViewControllers() {
        self.currentSegueIdentifier = (self.currentSegueIdentifier == kSegueIdentifierYouTube) ? kSegueIdentifierSoundCloud : kSegueIdentifierYouTube
        self.performSegue(withIdentifier: currentSegueIdentifier, sender: nil)
    }
    
    func mainViewController() {
        if currentSegueIdentifier == kSegueIdentifierSoundCloud {
            swapViewControllers()
        }
    }
    
    func peopleViewController() {
        if currentSegueIdentifier == kSegueIdentifierYouTube {
            swapViewControllers()
        }
    }

}
