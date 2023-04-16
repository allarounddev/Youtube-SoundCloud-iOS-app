//
//  ProfileStatisticsViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 19/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

enum ProfileStatisticsType: Int {
    case earnings
    case following
    case followers
    case blocked
    case friends
}

class ProfileStatisticsViewController: UIViewController, UserSelecting, UserStatusDelegate, MainViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    var dataSource: UserStatisticsDataSource?
    var type: ProfileStatisticsType = .following
    var profileDelegate: ProfileDelegate?

    func configureView() {
        emptyLabel.text = NSLocalizedString("table_no_data", comment: "")
        
        switch type {
        case .following:    title = NSLocalizedString("profile_following", comment: "")
        case .followers:    title = NSLocalizedString("profile_followers", comment: "")
        case .blocked:      title = NSLocalizedString("profile_blocked", comment: "")
        case .friends:      title = NSLocalizedString("friends", comment: "")
        default:
            break;
        }
        
        tableView.tableFooterView = UIView()
        tableView.addPullToRefresh { () -> Void in
            self.dataSource!.reload()
        }
//        if type != .streams {
//            tableView.addInfiniteScrolling { () -> Void in
//                self.dataSource!.fetchMore()
//            }
//        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

        let userId = UserContainer.shared.logged().id
        dataSource = UserStatisticsDataSource.create(type, userId: userId, tableView: tableView)
        dataSource!.profileDelegate = profileDelegate
        dataSource!.userSelectedDelegate = self
        dataSource!.reload()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "ProfileStatisticsToJoinStream" {
                let navigationController = segue.destination as! UINavigationController
                let controller = navigationController.viewControllers[0] as! JoinStreamViewController
                controller.stream = (sender as! StreamCell).stream
                print(controller.stream!)
                controller.isRecent = true
                controller.delegate = self
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - MainViewControllerDelegate
    
    func streamListReload() {
        dataSource!.reload()
    }
    
    func changeMode(_ isGlobal: Bool) {
    }
    
    func goStream() {
    }
    // MARK: - UserSelecting
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: self)
    }
    
    // MARK: - UserStatusDelegate
    
    func followStatusDidChange(_ status: Bool, user: User) {
        dataSource!.updateFollowedStatus(user, status: status)
        profileDelegate!.reload()
    }
    
    func blockStatusDidChange(_ status: Bool, user: User) {
        dataSource!.updateBlockedStatus(user, status: status)
        profileDelegate!.reload()
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
