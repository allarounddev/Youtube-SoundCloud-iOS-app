//
//  EpisodesVC.swift
//  Streamini
//
//  Created by developer on 12/1/18.
//  Copyright © 2018 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit


class EpisodesVC: BaseViewController, UserSelecting, StreamDataSourceDelegate, MainViewControllerDelegate {
    func showInfo() {
        
    }
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    let dataSource  = EpisodesDataSource()
    var profileDelegate: ProfileDelegate?

    var track:Track?
    var stream: Stream?
    
    var videoID: String?
    var avatarStr: String?
    var listIndex: Int?
    
    override func viewDidLoad() {

        title = NSLocalizedString("profile_streams", comment: "")

        dataSource.profileDelegate = profileDelegate
        dataSource.userSelectedDelegate = self

        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        configureView()

        collectionView.addPullToRefresh { () -> Void in
            StreamConnector().my(self.successStreams, failure: self.failureStream)
        }
        dataSource.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(refreshEpisodesData(_:)), name: NSNotification.Name(rawValue: "refreshEpisodesData"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StreamConnector().my(successStreams, failure: failureStream)
        UIApplication.shared.setStatusBarHidden(false, with: .none)

    }
    
    @objc func refreshEpisodesData(_ notificatoin: NSNotification) {
        StreamConnector().my(successStreams, failure: failureStream)
    }
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - Memory management
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        performSegue(withIdentifier: "EpisodesToJoin", sender: nil)
    }
    
    
    
    func streamListReload() {
        StreamConnector().my(successStreams, failure: failureStream)
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        dataSource.userSelectedDelegate = self
//        collectionView.register(EpisodesCollectionCell.self, forCellWithReuseIdentifier: "EpisodesCollectionCell")

    }
    
    func changeMode(_ isGlobal: Bool) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "EpisodesToJoin" {
                let navigationController = segue.destination as! UINavigationController
                let controller = navigationController.viewControllers[0] as! JoinStreamViewController
                if sender == nil {
                    controller.stream = GStream
                } else {
                    controller.stream = (sender as! StreamCell).stream
                }
                controller.isRecent = (sid == "EpisodesToJoin")
                controller.delegate = self
            }
        }
    }

}
