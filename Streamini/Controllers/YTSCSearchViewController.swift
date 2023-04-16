//
//  YTSCSearchViewController.swift
//  Streamini
//
//  Created by sergiy on 10/11/17.
//  Copyright © 2017 UniProgy s.r.o. All rights reserved.
//

import Foundation

class YTSCSearchViewController: UIViewController {
    

    @IBOutlet weak var ytButton: UIButton!
    @IBOutlet weak var scButton: UIButton!
    var containerViewController: YTSCContainerViewController?
    
    @IBOutlet weak var containerView: UIView!
    weak var currentViewController: UIViewController?

    override func viewDidLoad() {
        
        self.currentViewController = self.storyboard?.instantiateViewController(withIdentifier: "youtube")
        self.currentViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.addChild(self.currentViewController!)
        self.addSubview(subView: self.currentViewController!.view, toView: self.containerView)

        super.viewDidLoad()
        self.title = "GLOBAL"
        self.navigationController!.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        ytButton.backgroundColor = UIColor(red: 10/255, green: 81/255, blue: 163/255, alpha: 1.0)
        ytButton.imageView?.contentMode = .scaleAspectFit
        scButton.backgroundColor = UIColor.white
        ytButton.setTitleColor(.white, for: .normal)
//        ytButton.setImageTintColor(.white, for: .normal)
        scButton.setTitleColor(.black, for: .normal)
//        scButton.setImageTintColor(.black, for: .normal)
        scButton.imageView?.contentMode = .scaleAspectFit

    }
    
    func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)

    }
    
    // MARK: - Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func scSearchButtonClicked(_ sender: Any) {
        scButton.backgroundColor = UIColor(red: 10/255, green: 81/255, blue: 163/255, alpha: 1.0)
        ytButton.backgroundColor = UIColor.white

        scButton.setTitleColor(.white, for: .normal)
//        scButton.setImageTintColor(.white, for: .normal)
        ytButton.setTitleColor(.black, for: .normal)
//        ytButton.setImageTintColor(.black, for: .normal)
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "soundcloud")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController


    }
    @IBAction func ytSearchButtonClicked(_ sender: Any) {
        ytButton.backgroundColor = UIColor(red: 10/255, green: 81/255, blue: 163/255, alpha: 1.0)
        scButton.backgroundColor = UIColor.white

        ytButton.setTitleColor(.white, for: .normal)
//        ytButton.setImageTintColor(.white, for: .normal)
        scButton.setTitleColor(.black, for: .normal)
//        scButton.setImageTintColor(.black, for: .normal)
        
        let newViewController = self.storyboard?.instantiateViewController(withIdentifier: "youtube")
        newViewController!.view.translatesAutoresizingMaskIntoConstraints = false
        self.cycleFromViewController(oldViewController: self.currentViewController!, toViewController: newViewController!)
        self.currentViewController = newViewController

        
    }
    
    func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        self.addChild(newViewController)
        self.addSubview(subView: newViewController.view, toView:self.containerView!)
        // TODO: Set the starting state of your constraints here
        newViewController.view.layoutIfNeeded()
        
        // TODO: Set the ending state of your constraints here
        
        UIView.animate(withDuration: 0.5, animations: {
            // only need to call layoutIfNeeded here
            newViewController.view.layoutIfNeeded()
        },
                                   completion: { finished in
                                    oldViewController.view.removeFromSuperview()
                                    oldViewController.removeFromParent()
                                    newViewController.didMove(toParent: self)
        })
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "RootToYTSCContainer" {
                containerViewController = segue.destination as? YTSCContainerViewController
                containerViewController!.parentController = self
            }
            
//            if sid == "RootToProfile" {
//                let peopleController = containerViewController!.childViewControllers[0] as! PeopleViewController
//                let profileController = segue.destination as! ProfileViewController
//                profileController.profileDelegate = peopleController
//            }
//            
//            if sid == "RootToYTSC" {
//                let YTSCSearchViewController = segue.destination as? YTSCSearchViewController
//            }
        }
    }


}
