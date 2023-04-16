//
//  MainViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate: class {
    func streamListReload()
    func changeMode(_ isGlobal: Bool)
}

class MainViewController: BaseViewController, MainViewControllerDelegate, UserSelecting, StreamDataSourceDelegate, InfoViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate {
    
    
    @IBOutlet weak var infoView: InfoView!
//    var infoViewDelegate: JoinInfoViewDelegate?

    @IBOutlet weak var tableView: UITableView!
    let dataSource  = StreamDataSource()
    weak var rootControllerDelegate: RootViewControllerDelegate?
    var isGlobal    = false
    var timer: Timer?
    
    var alertViewDelegate: UIAlertViewDelegate?
    var actionSheetDelegate: UIActionSheetDelegate?
    var actionSheetView: UIView?

    // MARK: - Network responses
    
    func successStreams(_ live: [Stream], recent: [Stream]) {
        self.tableView.pullToRefreshView.stopAnimating()

        dataSource.lives  = live//live.sorted({ (stream1, stream2) -> Bool in stream1.id > stream2.id })
        dataSource.recent = recent//recent.sorted({ (stream1, stream2) -> Bool in stream1.id > stream2.id })
        
        tableView.reloadData()
        
        if let delegate = rootControllerDelegate {
            delegate.modeDidChange(isGlobal)
        }
    }
    
    func failureStream(_ error: NSError) {
        handleError(error)
        self.tableView.pullToRefreshView.stopAnimating()
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func successUser(_ user: User) {
        UserContainer.shared.setLogged(user)
    }
    
    func failureUser(_ error: NSError) {
        handleError(error)
    }
    
    func goStream() {
        performSegue(withIdentifier: "MainRecentToJoinStream", sender: nil)
    }

    func showInfo() {
        infoView.stream = GStream
        infoView.show(false)
    }
    
    // MARK: - MainViewControllerDelegate
    
    func streamListReload() {
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
    }
    
    func changeMode(_ isGlobal: Bool) {
        self.isGlobal = isGlobal
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
        
        if let delegate = rootControllerDelegate {
            delegate.modeDidChange(isGlobal)
        }
    }
    
    // MARK: - Update
    
    @objc func reload(_ timer: Timer) {
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
    }    
    
    // MARK: - View life cycle
    
    func configureView() {
        dataSource.userSelectedDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        self.infoView.delegate = self
        self.infoView.userSelectingDelegate = self

        alertViewDelegate = self
        actionSheetDelegate = self
        actionSheetView = self.view

        self.isGlobal = UserDefaults.standard.bool(forKey: "isGlobalStreamsInMain")

        tableView.delegate   = dataSource
        tableView.dataSource = dataSource
        tableView.addPullToRefresh { () -> Void in
            StreamConnector().streams(self.isGlobal, success: self.successStreams, failure: self.failureStream)
        }
        UserConnector().get(nil, success: successUser, failure: failureUser)
        changeMode(isGlobal)
        dataSource.delegate = self
        self.timer = Timer(timeInterval: TimeInterval(10.0), target: self, selector: #selector(MainViewController.reload(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StreamConnector().streams(isGlobal, success: successStreams, failure: failureStream)
        if timer == nil {
            self.timer = Timer(timeInterval: TimeInterval(10.0), target: self, selector: #selector(MainViewController.reload(_:)), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
        }
        UIApplication.shared.setStatusBarHidden(false, with: .none)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer!.invalidate()
        timer = nil
    }
    
    func infoViewWillBeShown(_ infoView: InfoView) {
        infoView.update(GStream!)
    }
    
    func infoViewWillBeHidden(_ infoView: InfoView) {
        
    }
    
    func reportButtonPressed() {
        UIAlertView.reportConfirmationAlert(GStream!.title, delegate: alertViewDelegate!).show()
    }
    
    func shareButtonPressed() {
        UIActionSheet.shareActionSheet(actionSheetDelegate!).show(in: actionSheetView!)
    }

    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            StreamConnector().share(GStream!.id, usersId: nil, success: successWithoutAction, failure: failureWithoutAction)
        }
        if buttonIndex == 2 {
            self.performSegue(withIdentifier: "MainToFollowers", sender: self)
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            StreamConnector().report(GStream!.id, success: successWithoutAction, failure: failureWithoutAction)
        }
    }

    func successWithoutAction() {
        
    }
    
    func failureWithoutAction(_ error: NSError) {
        handleError(error)
    }

    @IBAction func authorImageViewPressed(_ sender: AnyObject) {
        self.showUserInfo(GStream!.user, userStatusDelegate: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "MainToJoinStream" || sid == "MainRecentToJoinStream" {
                let navigationController = segue.destination as! UINavigationController
                let controller = navigationController.viewControllers[0] as! JoinStreamViewController
                if sender == nil {
                    controller.stream = GStream
                } else {
                    controller.stream = (sender as! StreamCell).stream
                }
                controller.isRecent = (sid == "MainRecentToJoinStream")
                controller.delegate = self
            }
        }
    }
    
    // MARK: - UserSelecting protocol
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
