//
//  PeopleViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController, UserSelecting, StreamSelecting, ProfileDelegate, UISearchBarDelegate, UserStatusDelegate {
    var dataSource: SearchDataSource?
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTypeSegment: UISegmentedControl!
    
    var isSearchMode = true
    
    @IBAction func changeMode(_ sender: AnyObject) {
        switch searchTypeSegment.selectedSegmentIndex
        {
        case 0:
            searchBar.resignFirstResponder()
            dataSource?.changeMode("streams")
            break;
        case 1:
            searchBar.resignFirstResponder()
            dataSource?.changeMode("places")
            break;
        default:
            dataSource?.changeMode("people")
            break; 
        }
    }

    // MARK: - UISearchBarDelegate
    
    // called when cancel button pressed
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // called when text changes (including clear)
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1 && (dataSource!.mode == "streams" || dataSource!.mode == "people") {
            dataSource!.search(searchText)
        }
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        
        tableView.tableFooterView = UIView()
        tableView.addInfiniteScrolling { () -> Void in
            self.dataSource!.fetchMore()
        }
        
        self.dataSource = SearchDataSource(tableView: tableView)
        dataSource!.userSelectedDelegate = self
        dataSource!.streamSelectedDelegate = self
        
        searchTypeSegment.setTitle(NSLocalizedString("broadcasts", comment: ""), forSegmentAt: 0)
        searchTypeSegment.setTitle(NSLocalizedString("places", comment: ""), forSegmentAt: 1)
        searchTypeSegment.setTitle(NSLocalizedString("people", comment: ""), forSegmentAt: 2)
        
        //self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        // dataSource!.reload()
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.setStatusBarHidden(false, with: .fade)
        UINavigationBar.setCustomAppereance()
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
    
    // MARK: - SearchSelecting protocol
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: self)
        searchBar.resignFirstResponder()
    }
    
    func streamDidSelected(_ stream: Stream) {
        // Load join controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let joinNavController = storyboard.instantiateViewController(withIdentifier: "JoinStreamNavigationControllerId") as! UINavigationController
        let joinController = joinNavController.viewControllers[0] as! JoinStreamViewController
        
        // Setup joinController
        joinController.stream   = stream
        joinController.isRecent = (stream.ended != nil)
        
        // Show JoinController
        self.present(joinNavController, animated: true, completion: nil)
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
