//
//  SoundCloudSearchViewController.swift
//  Streamini
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class SoundCloudSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UITextFieldDelegate {
    
    
    fileprivate var tracks: [Track]?
    fileprivate var filteredTracks: [Track]?
    
    fileprivate var lastTrackResponse: PaginatedAPIResponse<Track>? {
        didSet {
            self.tableView.isUserInteractionEnabled = true
            tableView?.reloadData()
        }
    }
    
    var trackResponse: PaginatedAPIResponse<Track>? {
        didSet {
            tracks = trackResponse?.response.result
            lastTrackResponse = trackResponse
        }
    }

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentInfoLabel: UILabel!
    
    fileprivate var loading = false
    var searchActive : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SoundCloud"
        getNewMusic()

//        configView()
    }

    // MARK: Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.searchBar.delegate = self
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    
    // MARK: Search
    fileprivate func search(for content: String) {
        guard !content.isEmpty else { return }
        loadingIndicator?.startAnimating()
        
        Track.search(queries: [.queryString(content)]) { [weak self] response in
            self?.loadingIndicator?.stopAnimating()
            
            if case .failure(let error) = response.response {
                dump(error)
            } else {
                self?.trackResponse = response
            }
        }
    }
    
    func getNewMusic() {
        
        Track.searchTrending(queries: [.queryString("")]) { [weak self] response in
            
            if case .failure(let error) = response.response {
                dump(error)
            } else {
                self?.trackResponse = response
                //self?.performSegue(withIdentifier: "Tracks", sender: response)
            }
        }
        
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShareSCMusic" {
            guard let destinationViewController = segue.destination as? SoundCloudCreateShareViewController else { return }
            guard let track = sender as? Track else { return }
            destinationViewController.track = track
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tracks?.count && !loading {
            loading = true
            //Now we have to unwrap the optional because of https://bugs.swift.org/browse/SR-1681
            guard let lastTrackResponse = lastTrackResponse else {
                return
            }
            lastTrackResponse.fetchNextPage { [weak self] response in
                self?.loading = false
                
                if case .success(let tracks) = response.response {
                    self?.tracks?.append(contentsOf: tracks)
                }
                self?.lastTrackResponse = response
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        let track = tracks?[indexPath.row]
        self.performSegue(withIdentifier: "toShareSCMusic", sender: track)
    }
    
    
    //MARK: TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if(searchActive) {
//            return filteredTracks!.count
//        }
        return (tracks?.count ?? 0) + (lastTrackResponse?.hasNextPage == true ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == tracks?.count {
            return tableView.dequeueReusableCell(withIdentifier: "Loading", for: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicCell", for: indexPath)
        if let cell = cell as? MusicCell {
//            if(searchActive){
//                cell.track = filteredTracks?[indexPath.row]
//            } else {
//                cell.track = tracks?[indexPath.row]
//            }

            cell.track = tracks?[indexPath.row]
        }
        

        return cell
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        print(searchText)
        
//        filteredTracks = tracks?.filter { $0.title.range(of: searchText) != nil }
//
//        print(filteredTracks!)
//        if(filteredTracks?.count == 0 || searchText == ""){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
        search(for: searchBar.text!)

        tableView.reloadData()

    }
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchActive = true
//    }
//
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchActive = false
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchActive = false
//    }
//
//
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        searchActive = true;

        search(for: searchBar.text!)
        tableView.reloadData()

//        filteredTracks = tracks?.filter { $0.title.range(of: searchBar.text!) != nil }
//        tableView.reloadData()
//        searchBar.endEditing(true)

    }

}


