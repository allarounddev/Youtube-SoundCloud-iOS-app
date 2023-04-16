//
//  ContainerViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    let kSegueIdentifierMain    = "embedMain"
    let kSegueIdentifierPeople  = "embedPeople"
    var currentSegueIdentifier  = "embedMain"
    
    var parentController: RootViewController?

    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegue(withIdentifier: kSegueIdentifierMain, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            let destinationController = segue.destination 
            
            if sid == kSegueIdentifierMain {
                (destinationController as! MainViewController).rootControllerDelegate = parentController!
                parentController!.delegate = (destinationController as! MainViewController)
                
                if self.children.count > 0 {
                    swapFromViewController(children[0] , toViewController: destinationController)
                } else {
                    self.addChild(destinationController)
                    destinationController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    self.view.addSubview(destinationController.view)
                    segue.destination.didMove(toParent: self)
                }
            } else if segue.identifier == kSegueIdentifierPeople {
                self.swapFromViewController(children[0] , toViewController: destinationController)

            }
        }
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
        self.currentSegueIdentifier = (self.currentSegueIdentifier == kSegueIdentifierMain) ? kSegueIdentifierPeople : kSegueIdentifierMain
        self.performSegue(withIdentifier: currentSegueIdentifier, sender: nil)
    }
    
    func mainViewController() {
        if currentSegueIdentifier == kSegueIdentifierPeople {
            swapViewControllers()
        }
    }
    
    func peopleViewController() {
        if currentSegueIdentifier == kSegueIdentifierMain {
            swapViewControllers()
        }
    }
    
    // MARK: - Memmory management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
