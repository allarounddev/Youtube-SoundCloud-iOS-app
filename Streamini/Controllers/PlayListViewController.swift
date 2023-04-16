//
//  PlayListViewController.swift
//  Streamini
//
//  Created by developer on 7/28/18.
//  Copyright © 2018 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit


class PlayListViewController: BaseViewController, UserSelecting, StreamDataSourceDelegate, MainViewControllerDelegate {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource  = PlayListDataSource()

    var track:Track?
    var stream: Stream?

    var videoID: String?
    var avatarStr: String?
    var listIndex: Int?
    
    override func viewDidLoad() {

        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        configureView()
        collectionView.addPullToRefresh { () -> Void in
            StreamConnector().myplaylist(self.successStreams, failure: self.failureStream)
        }
        dataSource.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshData(_:)), name: NSNotification.Name(rawValue: "refreshData"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StreamConnector().myplaylist(successStreams, failure: failureStream)
        UIApplication.shared.setStatusBarHidden(false, with: .none)

    }
    
    @objc func refreshData(_ notificatoin: NSNotification) {
        StreamConnector().myplaylist(successStreams, failure: failureStream)
    }

    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func closeBtnClicked(_ sender: Any) {

        self.dismiss(animated: true, completion: nil)
    }
    
    func successStreams(_ streams: [Stream]) {
        
        self.collectionView.pullToRefreshView.stopAnimating()
        
        dataSource.streams = streams
        collectionView.reloadData()
        
    }
    
    func failureStream(_ error: NSError) {
        handleError(error)
        self.collectionView.pullToRefreshView.stopAnimating()
//        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func successUser(_ user: User) {
        UserContainer.shared.setLogged(user)
    }
    
    func failureUser(_ error: NSError) {
        handleError(error)
    }
    
    func goStream() {
        performSegue(withIdentifier: "PlayListToJoin", sender: nil)
    }
    

    
    func streamListReload() {
        StreamConnector().myplaylist(successStreams, failure: failureStream)
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        dataSource.userSelectedDelegate = self
    }

    func changeMode(_ isGlobal: Bool) {
        
    }

    func showInfo() {
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "PlayListToJoin" {
                let navigationController = segue.destination as! UINavigationController
                let controller = navigationController.viewControllers[0] as! JoinStreamViewController
                if sender == nil {
                    controller.stream = GStream
                } else {
                    controller.stream = (sender as! StreamCell).stream
                }
                controller.isRecent = (sid == "PlayListToJoin")
                controller.delegate = self
            }
        }
    }

}

