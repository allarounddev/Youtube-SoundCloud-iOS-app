//
//  FollowerActionDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class UserStatisticsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, LinkedUserCellDelegate {
    let userId: UInt
    var users: [User] = []
    var page: UInt = 0
    var tableView: UITableView
    var selectedCells: [LinkedUserCell] = []
    var profileDelegate: ProfileDelegate?
    var userSelectedDelegate: UserSelecting?
    var streamSelectedDelegate: StreamSelecting?
    
    // MARK: - Factory methods
    
    class func create(_ type: ProfileStatisticsType, userId: UInt, tableView: UITableView) -> UserStatisticsDataSource? {
        switch type {
        case .following:
            return FollowingDataSource(userId: userId, tableView: tableView)
        case .followers:
            return FollowersDataSource(userId: userId, tableView: tableView)
        case .blocked:
            return BlockedDataSource(userId: userId, tableView: tableView)
//        case .streams:
//            return MyStreamsDataSource(userId: userId, tableView: tableView)
        case .friends:
            return FriendsDataSource(userId: userId, tableView: tableView)
        default:
            return nil
        }
    }
    
    // MARK: - Object life cycle
    
    init(userId: UInt, tableView: UITableView) {
        self.userId      = userId
        self.tableView   = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    // MARK: - UITableViewDatasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedUserCell", for: indexPath) as! LinkedUserCell
        
        let user = users[indexPath.row]
        cell.update(user)
        cell.delegate = self
        return cell
    }
    
    // MARK: - LinkedCellDelegate
    
    func willStatusChanged(_ cell: UITableViewCell) {
        let selectedCell = cell as! LinkedUserCell
        self.selectedCells.append(selectedCell)
        
        let index = tableView.indexPath(for: cell)!.row
        let userId = users[index].id
        selectedCell.userStatusButton.isEnabled = false
        
        let connector = SocialConnector()
        if selectedCell.isStatusOn {
            connector.unfollow(userId, success: unfollowSuccess, failure: followActionFailure)
        } else {
            connector.follow(userId, success: followSuccess, failure: followActionFailure)
        }
    }
    
    // MARK: - Network communication
    
    func unfollowSuccess() {
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = false
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
        
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func followSuccess() {
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = true
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
        
        if let delegate = profileDelegate {
            delegate.reload()
        }
    }
    
    func followActionFailure(_ error: NSError) {
        let selectedCell = self.selectedCells[0]
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
    }
    
    func statisticsDataSuccess(_ users: [User]) {
        if let pullToRefreshView = tableView.pullToRefreshView {
            pullToRefreshView.stopAnimating()
        }
        self.users = users        
        tableView.isHidden = self.users.isEmpty
        
        let range = NSMakeRange(0, tableView.numberOfSections)
        let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
        tableView.reloadSections(indexSet, with: UITableView.RowAnimation.automatic)
    }
    
    func moreStatisticsDataSuccess(_ users: [User]) {
        if let pullToRefreshView = tableView.pullToRefreshView {
            pullToRefreshView.stopAnimating()
        }
        if let infiniteScrollingView = tableView.infiniteScrollingView {
            infiniteScrollingView.stopAnimating()
        }
        
        self.users = self.users + users
        tableView.isHidden = self.users.isEmpty
        tableView.reloadData()
    }
    
    func statisticsDataFailure(_ error: NSError) {
        if let pullToRefreshView = tableView.pullToRefreshView {
            pullToRefreshView.stopAnimating()
        }
        if let infiniteScrollingView = tableView.infiniteScrollingView {
            infiniteScrollingView.stopAnimating()
        }
        
        print("get user failed: \(error.localizedDescription)")
    }
    
    // MARK: - Reload methods
    
    func reload() {
        assert(false, "This method must be overriden by the subclass")
    }
    
    func fetchMore() {
       assert(false, "This method must be overriden by the subclass")        
    }
    
    func clean() {
        users = []
        tableView.reloadData()
    }
    
    func updateFollowedStatus(_ user: User, status: Bool) {
        var updateObject = users.filter({ $0.id == user.id })
        if updateObject.count > 0 {
            updateObject[0].isFollowed = status
            let index = (users as NSArray).index(of: updateObject[0])
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            return
        }
    }
    
    func updateBlockedStatus(_ user: User, status: Bool) {
        var updateObject = users.filter({ $0.id == user.id })
        if updateObject.count > 0 {
            updateObject[0].isBlocked = status
            let index = (users as NSArray).index(of: updateObject[0])
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            return
        }
    }
}
