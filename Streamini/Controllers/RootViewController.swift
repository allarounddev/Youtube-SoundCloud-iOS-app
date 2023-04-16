//
//  RootViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 11/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit
import Photos

protocol RootViewControllerDelegate: class {
    func modeDidChange(_ isGlobal: Bool)
}

class RootViewController: BaseViewController, RootViewControllerDelegate {
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var recButton: UIButton!
    @IBOutlet weak var peopleButton: UIButton!    
    @IBOutlet weak var containerView: UIView!
    var containerViewController: ContainerViewController?
    
    weak var delegate: MainViewControllerDelegate?
    var isGlobal = false
    
    // MARK: - Actions
    
    @IBAction func recButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "RootToCreate", sender: self)
    }
    
    @IBAction func peopleButtonPressed(_ sender: AnyObject) {
        containerViewController!.peopleViewController()
        homeButton.isSelected   = false
        peopleButton.isSelected = true
        setupPeopleNavigationItems()
    }
    
    @IBAction func mainButtonPressed(_ sender: AnyObject) {
        containerViewController!.mainViewController()
        homeButton.isSelected   = true
        peopleButton.isSelected = false
        setupMainNavigationItems()
    }
    
    @objc func profileButtonItemPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "RootToProfile", sender: nil)
    }
    
    @objc func globalButtonItemPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "RootToYTSC", sender: self)
    }

    @objc func searchButtonItemPressed(_ sender: AnyObject) {
        let peopleController = containerViewController!.children[0] as! PeopleViewController
        if peopleController.isSearchMode {
            peopleController.hideSearch(true)
            peopleController.dataSource!.reload()
        } else {
            peopleController.showSearch(true)
        }
    }
    
    // MARK: - Setup Navigation Items
    
    func setupPeopleNavigationItems() {
        self.title = NSLocalizedString("people_title", comment: "")
        
        let leftButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        leftButton.setImage(UIImage(named: "search"), for: UIControl.State())
        leftButton.addTarget(self, action: #selector(RootViewController.searchButtonItemPressed(_:)), for: UIControl.Event.touchUpInside)
        leftButton.setImageTintColor(UIColor.black, for: UIControl.State())
        leftButton.setImageTintColor(UIColor.black, for: UIControl.State.highlighted)
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        let leftButton1 = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0))
        leftButton1.setImage(UIImage(named: "fire"), for: UIControl.State())
        leftButton1.addTarget(self, action: #selector(fireTapped(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem1 = UIBarButtonItem(customView: leftButton1)

        let rightButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        rightButton.setImage(UIImage(named: "profile"), for: UIControl.State())
        rightButton.addTarget(self, action: #selector(RootViewController.profileButtonItemPressed(_:)), for: UIControl.Event.touchUpInside)
        rightButton.setImageTintColor(UIColor.black, for: UIControl.State())
        rightButton.setImageTintColor(UIColor.black, for: UIControl.State.highlighted)
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        let rightButton1 = UIButton(frame: CGRect(x: 25.0, y: 0.0, width: 60.0, height: 40.0))
        rightButton1.setImage(UIImage(named: "hand"), for: UIControl.State())
        rightButton1.addTarget(self, action: #selector(handTapped(_:)), for: UIControl.Event.touchUpInside)
        let rightBarButtonItem1 = UIBarButtonItem(customView: rightButton1)
        
        self.navigationItem.leftBarButtonItems  = [leftBarButtonItem, leftBarButtonItem1]
        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, rightBarButtonItem1]
    }
    
    func setupMainNavigationItems() {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        let itemImage: UIImage
        if isGlobal {
            self.title = NSLocalizedString("global_title",  comment: "")
            itemImage = UIImage(named: "following")!
        } else {
            self.title = NSLocalizedString("followed_title",  comment: "")
            itemImage = UIImage(named: "global")!
        }
        
        let rightButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        rightButton.setImage(itemImage, for: UIControl.State())
//        button.addTarget(self, action: #selector(RootViewController.modeChanged), for: UIControlEvents.touchUpInside)
        rightButton.addTarget(self, action: #selector(RootViewController.globalButtonItemPressed(_:)), for: UIControl.Event.touchUpInside)
        rightButton.setImageTintColor(UIColor.black, for: UIControl.State())
        rightButton.setImageTintColor(UIColor.black, for: UIControl.State.highlighted)
        let rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        
        let rightButton1 = UIButton(frame: CGRect(x: 25.0, y: 0.0, width: 60.0, height: 40.0))
        rightButton1.setImage(UIImage(named: "hand"), for: UIControl.State())
        rightButton1.addTarget(self, action: #selector(handTapped(_:)), for: UIControl.Event.touchUpInside)
        let rightBarButtonItem1 = UIBarButtonItem(customView: rightButton1)

        let leftButton = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        leftButton.setImage(UIImage(named: "search"), for: UIControl.State())
        leftButton.addTarget(self, action: #selector(searchTapped(_:)), for: UIControl.Event.touchUpInside)
        leftButton.setImageTintColor(UIColor.black, for: UIControl.State())
        leftButton.setImageTintColor(UIColor.black, for: UIControl.State.highlighted)
        let leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        
        let leftButton1 = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 60.0, height: 60.0))
        leftButton1.setImage(UIImage(named: "fire"), for: UIControl.State())
        leftButton1.addTarget(self, action: #selector(fireTapped(_:)), for: UIControl.Event.touchUpInside)
        let leftBarButtonItem1 = UIBarButtonItem(customView: leftButton1)

        self.navigationItem.rightBarButtonItems = [rightBarButtonItem, rightBarButtonItem1]
        self.navigationItem.leftBarButtonItems  = [leftBarButtonItem, leftBarButtonItem1]
    }
    
    // MARK: - RootViewControllerDelegate
    
    func modeDidChange(_ isGlobal: Bool) {
        self.isGlobal = isGlobal
        UserDefaults.standard.set(isGlobal, forKey: "isGlobalStreamsInMain")
        
        if homeButton.isSelected {
            setupMainNavigationItems()
        }
    }
    
    func modeChanged() {
        if let del = delegate {
            del.changeMode(!isGlobal)
        }
    }
    
    @objc func searchTapped(_ sender: AnyObject)
    {
        // Load controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SearchScreen")
        // Show Controller
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func fireTapped(_ sender: AnyObject)
    {
        // Load controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PlayListViewController")
        isPlaylist = true
        // Show Controller
        self.present(controller, animated: true, completion: nil)
    }

    @objc func handTapped(_ sender: AnyObject) {
        if let url = NSURL(string: "https://itunes.apple.com/us/podcast/taking-back-your-power/id1355853948?mt=2"){
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        self.navigationController!.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = true
        self.navigationController!.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Ultra", size: 18)!, NSAttributedString.Key.foregroundColor : UIColor.black]

        let normalStateColor = UIColor.buttonNormalColor()
        let highlightedStateColor = UIColor.black
        
        homeButton.setImageTintColor(normalStateColor, for: UIControl.State())
        homeButton.setImageTintColor(highlightedStateColor, for: UIControl.State.highlighted)
        homeButton.setImageTintColor(highlightedStateColor, for: UIControl.State.selected)
        homeButton.isSelected = true
        
        peopleButton.setImageTintColor(normalStateColor, for: UIControl.State())
        peopleButton.setImageTintColor(highlightedStateColor, for: UIControl.State.highlighted)
        peopleButton.setImageTintColor(highlightedStateColor, for: UIControl.State.selected)
        
        recButton.setImage(UIImage(named: "rec"), for: UIControl.State())
        recButton.setImage(UIImage(named: "rec"), for: UIControl.State.highlighted)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()        
        modeDidChange(false)
        
        // Ask for use CLLocationManager
        let _ = LocationManager.shared
        
        // Ask for use Camera
        if AVCaptureDevice.responds(to: #selector(AVCaptureDevice.requestAccess(for:completionHandler:))) {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) -> Void in
            })
        }
        
        // Ask for use Microphone
        if (AVAudioSession.sharedInstance().responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                //
            })
            
        }
        
        // Ask for use Photo Gallery
        if NSClassFromString("PHPhotoLibrary") != nil {
                if #available(iOS 8.0, *) {
                    PHPhotoLibrary.requestAuthorization { (status) -> Void in
                }
                } else {
                    // Fallback on earlier versions
                }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "RootToContainer" {
                containerViewController = segue.destination as? ContainerViewController
                containerViewController!.parentController = self
            }
            
            if sid == "RootToProfile" {
                let peopleController = containerViewController!.children[0] as! PeopleViewController
                let profileController = segue.destination as! ProfileViewController
                profileController.profileDelegate = peopleController
            }
            
//            if sid == "RootToYTSC" {
//                let YTSCSearchViewController = segue.destination as? YTSCSearchViewController
//            }
        }
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
