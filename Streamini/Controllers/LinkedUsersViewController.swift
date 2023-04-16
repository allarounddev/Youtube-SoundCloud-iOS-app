//
//  LinkedUsersViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 06/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class LinkedUsersViewController: UIViewController, UserStatisticsDelegate, StreamSelecting {
    @IBOutlet weak var selectorView: SelectorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var dataSource: UserStatisticsDataSource?
    var profileDelegate: ProfileDelegate?
    
    // MARK: - View life cycle
    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        emptyLabel.text = NSLocalizedString("table_no_data", comment: "")
        
        tableView.addPullToRefresh { () -> Void in
            self.dataSource!.reload()
        }

        tableView.addInfiniteScrolling { () -> Void in
            self.dataSource!.fetchMore()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        // Do any additional setup after loading the view.
    }
        
    // MARK: - StreamSelecting
    
    func streamDidSelected(_ stream: Stream) {
//        if(stream.videotype == "live") {
        
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
            
            if let delegate = profileDelegate {
                delegate.close()
            }
//        }
//        else {
//            let vc = YoutubePlayerViewController(nibName: "YoutubePlayerViewController", bundle: nil)
//            let extras:String = stream.extras
//            do {
//                let json = try JSONSerialization.jsonObject(with: extras.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
//                guard let videoId:String = json["videoId"] as? String else { return }
//                self.present(vc, animated: true, completion: { 
//                    vc.videoId = videoId
//                })
//            } catch let jsonError {
//                print(jsonError)
//            }
//
//        }
    }

    // MARK: - Memmory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        // reload header view
    }
    
    // MARK: - UserStatisticsDelegate
    
    func recentStreamsDidSelected(_ userId: UInt) {
        tableView.showsPullToRefresh     = false
        tableView.showsInfiniteScrolling = false
        selectorView.selectSection(0)
        self.dataSource = RecentStreamsDataSource(userId: userId, tableView: tableView)
        dataSource!.streamSelectedDelegate = self
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followersDidSelected(_ userId: UInt) {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(1)
        self.dataSource = FollowersDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()
        dataSource!.reload()
    }
    
    func followingDidSelected(_ userId: UInt) {
        tableView.showsPullToRefresh     = true
        tableView.showsInfiniteScrolling = true
        selectorView.selectSection(2)
        self.dataSource = FollowingDataSource(userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.clean()        
        dataSource!.reload()
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
