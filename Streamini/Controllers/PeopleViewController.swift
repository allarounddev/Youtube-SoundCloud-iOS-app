//
//  PeopleViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class PeopleViewController: BaseViewController, UserSelecting, ProfileDelegate, UISearchBarDelegate, UserStatusDelegate {
    var dataSource: PeopleDataSource?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchBarTop: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var isSearchMode = true
    
    // MARK: - Actions
    
    func showSearch(_ animated: Bool) {
        if !isSearchMode {
            if animated {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.searchBarTop.constant = 0
                    self.view.layoutIfNeeded()
                })
            } else {
                self.searchBarTop.constant = 0
                self.view.layoutIfNeeded()
            }
            isSearchMode = true
            searchBar.becomeFirstResponder()
        }
    }
    
    func hideSearch(_ animated: Bool) {
        if isSearchMode {
            if animated {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.searchBarTop.constant = -self.searchBar.bounds.size.height
                    self.view.layoutIfNeeded()
                })
            } else {
                self.searchBarTop.constant = -self.searchBar.bounds.size.height
                self.view.layoutIfNeeded()
            }
            isSearchMode = false
            dataSource!.isSearchMode = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    // called when cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        hideSearch(true)
        dataSource!.reload()
    }
    
    // called when text changes (including clear)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 {
            let data = NSDictionary(dictionary: ["p" : 0, "q" : searchText])
            dataSource!.isSearchMode = true
            dataSource!.search(data)
        }
    }
        
    // MARK: - View life cycle

    func configureView() {
        emptyLabel.text = NSLocalizedString("table_no_data", comment: "")
        
        tableView.tableFooterView = UIView()
        tableView.addPullToRefresh { () -> Void in
            self.dataSource!.reload()
        }
        tableView.addInfiniteScrolling { () -> Void in
            self.dataSource!.fetchMore()
        }
        
        self.dataSource = PeopleDataSource(tableView: tableView)
        dataSource!.userSelectedDelegate = self
        hideSearch(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        dataSource!.reload()
        // Do any additional setup after loading the view.

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        dataSource!.reload()
    }
    
    func close() {
    }    
    
    // MARK: - UserStatusDelegate
    
    func followStatusDidChange(_ status: Bool, user: User) {
        dataSource!.updateUser(user, isFollowed: status, isBlocked: user.isBlocked)
    }
    
    func blockStatusDidChange(_ status: Bool, user: User) {
        dataSource!.updateUser(user, isFollowed: user.isFollowed, isBlocked: status)
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: self)
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Memmory management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
