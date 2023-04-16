//
//  FollowersViewController.swift
// Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol SelectFollowersDelegate: class {
    func followersDidSelected(_ users: [User])
}

class FollowersViewController: BaseTableViewController, UISearchBarDelegate, UserSelecting {
    @IBOutlet weak var searchBar: UISearchBar!
    var users: [User]           = []
    var selectedUsers: [User]   = []
    var page                    = 0
    var searchTerm              = ""
    weak var delegate: SelectFollowersDelegate?
    
    // MARK: - Actions
    
    @objc func selectedDone() {
        if let del = delegate {
            if !selectedUsers.isEmpty {
                del.followersDidSelected(selectedUsers)
            }
        }
        self.navigationController!.popViewController(animated: true)
    }
    
    // MARK: - Network responses
    
    func followersSuccess(_ users: [User]) {
        self.users = users.filter( { $0.id != UserContainer.shared.logged().id } )
        
        let range = NSMakeRange(0, tableView.numberOfSections)
        let indexSet = IndexSet(integersIn: range.toRange() ?? 0..<0)
        tableView.reloadSections(indexSet, with: UITableView.RowAnimation.automatic)
    }
    
    func addFollowersSuccess(_ users: [User]) {
        tableView.infiniteScrollingView.stopAnimating()
        self.users += users.filter( { $0.id != UserContainer.shared.logged().id } )
        tableView.reloadData()
    }
    
    func followersFailure(_ error: NSError) {
        handleError(error)
        tableView.infiniteScrollingView.stopAnimating()
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        self.navigationController!.navigationBar.tintColor = UIColor.black
        self.title = NSLocalizedString("select_followers_title", comment: "")
        
        let buttonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(FollowersViewController.selectedDone))
        self.navigationItem.rightBarButtonItem = buttonItem
        
        self.tableView.addInfiniteScrolling { () -> Void in
            self.page += 1
            let data = NSDictionary(objects: [self.page, self.searchTerm], forKeys: ["p" as NSCopying, "q" as NSCopying])
            UserConnector().followers(data, success: self.addFollowersSuccess, failure: self.followersFailure)
        }
        
        self.searchBar.placeholder = NSLocalizedString("search_followers_placeholder", comment: "")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        let data = [ "p" : page ]
        UserConnector().followers(data as NSDictionary, success: followersSuccess, failure: followersFailure)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UITableView Delegate & DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "followerCell", for: indexPath) as! FollowerCell
        cell.userSelectedDelegate = self
        cell.update(user)
        
        return cell        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as! FollowerCell

        if selectedUsers.filter({ $0.id == user.id }).count > 0 {
            cell.checkmarkImageView.isHidden = true
            selectedUsers = selectedUsers.filter({ $0.id != user.id })
        } else {
            cell.checkmarkImageView.isHidden = false
            selectedUsers.append(user)
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        page = 0
        searchTerm = searchText
        let data = NSDictionary(objects: [page, searchTerm], forKeys: ["p" as NSCopying, "q" as NSCopying])
        UserConnector().followers(data, success: followersSuccess, failure: followersFailure)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        let data = [ "p" : 0 ]
        UserConnector().followers(data as NSDictionary, success: followersSuccess, failure: followersFailure)
        
        page            = 0
        searchTerm      = ""
        searchBar.text  = ""
        searchBar.resignFirstResponder()
    }
}
