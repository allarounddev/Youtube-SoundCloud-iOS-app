//
//  PeopleDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class PeopleDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, LinkedUserCellDelegate {
    var foundUsers: [User]  = []
    var top: [User]         = []
    var featured: [User]    = []
    var tableView: UITableView
    var selectedCells: [PeopleCell] = []
    var userSelectedDelegate: UserSelecting?
    var page: UInt          = 0
    var searchPage: UInt    = 0
    fileprivate let l = UILabel()
    
    var isSearchMode = false
    var searchData = NSMutableDictionary()
    
    init(tableView: UITableView) {
        self.tableView   = tableView
        super.init()
        tableView.dataSource = self
        tableView.delegate   = self
        
        l.font = UIFont(name: "HelveticNeue", size: 15.0)
        l.numberOfLines = 0
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
    }

    // MARK: - UITableViewDatasource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (isSearchMode) ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            return foundUsers.count
        } else {
            return (section == 0) ? top.count : featured.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath) as! PeopleCell
        
        let user: User
        if isSearchMode {
            user = foundUsers[indexPath.row]
        } else {
            user = (indexPath.section == 0) ? top[indexPath.row] : featured[indexPath.row]
        }
        
        cell.update(user)
        cell.delegate = self
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0 && top.isEmpty) || (section == 1 && featured.isEmpty) || isSearchMode {
            return 0.0
        }
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (section == 0 && top.isEmpty) || (section == 1 && featured.isEmpty) || isSearchMode {
            return nil
        }
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 35))
        header.backgroundColor = UIColor.clear
        
        let label = UILabel()
        
        if section == 0 {
            label.text = NSLocalizedString("people_top", comment: "")
        } else {
            label.text = NSLocalizedString("people_featured", comment: "")
        }
        
        label.font = UIFont(name: "HelveticaNeue", size: 17.0)
        label.frame = CGRect(x: 14, y: 0, width: tableView.bounds.size.width - 14.0, height: 35)
        label.textColor = UIColor.darkGray
        label.backgroundColor = UIColor.clear
        
        header.addSubview(label)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let user: User
        if isSearchMode {
            user = foundUsers[indexPath.row]
        } else {
            user = (indexPath.section == 0) ? top[indexPath.row] : featured[indexPath.row]
        }
        
        var text: String? = nil
        if user.desc != nil {
            if !user.desc!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                text = user.desc
            }
        }
        l.text = text
        let expectedSize = l.sizeThatFits(CGSize(width: tableView.bounds.size.width - 98.0, height: 1000))
        return expectedSize.height + 82.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let user: User
        if isSearchMode {
            user = foundUsers[indexPath.row]
        } else {
            user = (indexPath.section == 0) ? top[indexPath.row] : featured[indexPath.row]
        }
        
        if let delegate = userSelectedDelegate {
            delegate.userDidSelected(user)
        }
    }
    
    // MARK: - LinkedCellDelegate
    
    func willStatusChanged(_ cell: UITableViewCell) {
        let selectedCell = cell as! PeopleCell
        self.selectedCells.append(selectedCell)
        
        let indexPath = tableView.indexPath(for: cell)!
        
        let userId: UInt
        if isSearchMode {
            userId = foundUsers[indexPath.row].id
        } else {
            userId = (indexPath.section == 0) ? top[indexPath.row].id : featured[indexPath.row].id
        }
        
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
    }
    
    func followSuccess() {
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = true
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
    }
    
    func followActionFailure(_ error: NSError) {
        let selectedCell = self.selectedCells[0]
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
    }
    
    func peopleSuccess(_ top: [User], featured: [User]) {
        tableView.pullToRefreshView.stopAnimating()
        self.top        = top
        self.featured   = featured
    
        tableView.isHidden = (self.top.isEmpty && self.featured.isEmpty)        
        self.tableView.reloadData()
    }
    
    func fetchMoreSuccess(_ top: [User], featured: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.top        = self.top + top
        self.featured   = self.featured + featured
        
        tableView.isHidden = (self.top.isEmpty && self.featured.isEmpty)
        self.tableView.reloadData()
    }
    
    func searchSuccess(_ users: [User]) {
        self.foundUsers = users
        
        tableView.isHidden = self.foundUsers.isEmpty
        
        let range = NSMakeRange(0, tableView.numberOfSections)
        
        if range.length == 2 {
            UIView.transition(with: tableView, duration:TimeInterval(0.4), options:.transitionCrossDissolve, animations: { () -> Void in
                self.tableView.reloadData()
            }, completion: nil)
        } else {
            let range = NSMakeRange(0, tableView.numberOfSections)
            let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
            tableView.reloadSections(indexSet, with: UITableView.RowAnimation.automatic)
        }
    }
    
    func searchMoreSuccess(_ users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        
        self.foundUsers = self.foundUsers + users
        
        tableView.isHidden = self.foundUsers.isEmpty        
        self.tableView.reloadData()
    }
    
    func actionFailure(_ error: NSError) {
        tableView.pullToRefreshView.stopAnimating()
        print("get user failed: \(error.localizedDescription)")
    }
    
    // MARK: - Reload methods
    
    func updateUser(_ user: User, isFollowed: Bool, isBlocked: Bool) {
        if isSearchMode {
            var updateObject = foundUsers.filter({ $0.id == user.id })
            if updateObject.count > 0 {
                updateObject[0].isBlocked = isBlocked
                updateObject[0].isFollowed = isFollowed
                let index = (foundUsers as NSArray).index(of: updateObject[0])
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
            return
        }
        
        var updateObject = top.filter({ $0.id == user.id })
        if updateObject.count > 0 {
            updateObject[0].isBlocked = isBlocked
            updateObject[0].isFollowed = isFollowed
            let index = (top as NSArray).index(of: updateObject[0])
            let indexPath = IndexPath(row: index, section: 0)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            return
        }
        updateObject = featured.filter({ $0.id == user.id })
        if updateObject.count > 0 {
            updateObject[0].isBlocked = isBlocked
            updateObject[0].isFollowed = isFollowed
            let index = (featured as NSArray).index(of: updateObject[0])
            let indexPath = IndexPath(row: index, section: 1)
            tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            return
        }
    }
    
    func reload() {
        SocialConnector().users(NSDictionary(), success: peopleSuccess, failure: actionFailure)
    }
    
    func fetchMore() {
        if isSearchMode {
            searchPage = searchPage+1
            searchData["p"] = searchPage
            searchMore(searchData)
        } else {
            page += 1
            SocialConnector().users(NSDictionary(object: page, forKey: "p" as NSCopying), success: fetchMoreSuccess, failure: actionFailure)
        }
    }
    
    func search(_ data: NSDictionary) {
        searchPage = 0
        searchData = NSMutableDictionary(dictionary: data)
        SocialConnector().search(data, success: searchSuccess, failure: actionFailure)
    }
    
    func searchMore(_ data: NSDictionary) {
        SocialConnector().search(data, success: searchMoreSuccess, failure: actionFailure)
    }
}
