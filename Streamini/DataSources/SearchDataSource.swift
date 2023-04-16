//
//  PeopleDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class SearchDataSource: NSObject, UITableViewDataSource, UITableViewDelegate, LinkedUserCellDelegate {
    var users: [User] = []
    var streams: [Stream] = []
    var cities: [String] = []
    
    var tableView: UITableView
    var userSelectedDelegate: UserSelecting?
    var streamSelectedDelegate: StreamSelecting?
    var page: UInt = 0
    fileprivate let l = UILabel()
    
    var mode = "streams"
    
    var selectedCells: [PeopleCell] = []
    
    var city: String = ""
    var query: String = ""
    
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == "places" {
            return cities.count
        }
        else if mode == "streams" {
            return streams.count
        }
        else if mode == "people" {
            return users.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if mode == "places" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
            cell.textLabel!.text = cities[indexPath.row]
            return cell
        }
        else if mode == "streams" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "streamCell", for: indexPath) as! SearchStreamCell
            let stream = streams[indexPath.row]
            
            if let delegate = self.userSelectedDelegate {
                cell.userSelectedDelegate = delegate
            }
            cell.update(stream)
            return cell
        }
        else if mode == "people" {
            let cell: PeopleCell = tableView.dequeueReusableCell(withIdentifier: "peopleCell", for: indexPath) as! PeopleCell
            let user = users[indexPath.row]
            cell.update(user)
            cell.delegate = self
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if mode == "streams" {
            return 120.0
        }
        else if mode == "people" {
            let user = users[indexPath.row]
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
        
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if mode == "places" {
           // search cities
            self.city = cities[indexPath.row]
            self.query = ""
            changeMode("streams")
        }
        else if mode == "streams" {
            let s = streams[indexPath.row]
            if let delegate = streamSelectedDelegate {
                delegate.streamDidSelected(s)
            }
        }
        else if mode == "people" {
            let u = users[indexPath.row]
            if let delegate = userSelectedDelegate {
                delegate.userDidSelected(u)
            }
        }
    }
    
    // MARK: - LinkedCellDelegate
    
    func willStatusChanged(_ cell: UITableViewCell) {
        let selectedCell = cell as! PeopleCell
        self.selectedCells.append(selectedCell)
        
        let indexPath = tableView.indexPath(for: cell)!
        
        let userId = users[indexPath.row].id
        
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
        if mode != "people" {
            return
        }
        
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = false
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
    }
    
    func followSuccess() {
        if mode != "people" {
            return
        }
        
        let selectedCell = self.selectedCells[0]
        selectedCell.isStatusOn = true
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
    }
    
    func followActionFailure(_ error: NSError) {
        if mode != "people" {
            return
        }
        
        let selectedCell = self.selectedCells[0]
        selectedCell.userStatusButton.isEnabled = true
        selectedCells.remove(at: 0)
    }
    
    func citiesSuccess(_ cities: [String]) {
        self.cities = cities
        tableView.reloadData()
        tableView.isHidden = self.cities.isEmpty
    }
    
    func peopleSuccess(_ users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users = users
        tableView.isHidden = self.users.isEmpty
        tableView.reloadData()
    }
    
    func streamsSuccess(_ streams: [Stream]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.streams = streams
        tableView.isHidden = self.streams.isEmpty
        tableView.reloadData()
    }
    
    func peopleMoreSuccess(_ users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users        = self.users + users
        tableView.isHidden = self.users.isEmpty
        tableView.reloadData()
    }
    
    func streamsMoreSuccess(_ streams: [Stream]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.streams        = self.streams + streams
        tableView.isHidden = self.streams.isEmpty
        tableView.reloadData()
    }
    
    
    func actionFailure(_ error: NSError) {
        //tableView.pullToRefreshView.stopAnimating()
        print("get user failed: \(error.localizedDescription)")
    }
    
    // MARK: - Reload methods
    
    func updateUser(_ user: User, isFollowed: Bool, isBlocked: Bool) {
            var updateObject = users.filter({ $0.id == user.id })
            if updateObject.count > 0 {
                updateObject[0].isBlocked = isBlocked
                updateObject[0].isFollowed = isFollowed
                let index = (users as NSArray).index(of: updateObject[0])
                let indexPath = IndexPath(row: index, section: 0)
                tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
            }
            return
    }
    
    func changeMode(_ mode:String)
    {
        self.mode = mode
        page = 0
        reload()
    }
    
    func reload() {
        //SocialConnector().users(NSDictionary(), success: peopleSuccess, failure: actionFailure)
        
        tableView.isHidden = true
        
        if mode == "places" {
            StreamConnector().cities(citiesSuccess, failure: actionFailure)
        }
        else if mode == "streams" {
            StreamConnector().search(0, query: query, city: city, success: streamsSuccess, failure: actionFailure)
        }
        else if mode == "people" {
            SocialConnector().search(NSDictionary(object: query, forKey: "q" as NSCopying), success: peopleSuccess, failure: actionFailure)
        }
    }
    
    func fetchMore() {
        
        if mode == "places" {
            tableView.infiniteScrollingView.stopAnimating()
            // do nothing        
        }
        else if mode == "streams" {
            page = page+1
            StreamConnector().search(page, query: query, city: city, success: streamsSuccess, failure: actionFailure)
        }
        else if mode == "people" {
            page = page+1
            SocialConnector().search(NSDictionary(objects: [page, query], forKeys: ["p" as NSCopying,"q" as NSCopying]), success: peopleSuccess, failure: actionFailure)
        }
    }
    
    func search(_ q: String)
    {
        self.query = q
        self.city = ""
        self.page = 0
        reload()
    }
}
