//
//  YoutubeSearchViewController.swift
//  Streamini
//

import UIKit

//private let _defaultEngine: Engine = {
//    let engine = Engine(.key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
//    engine.logEnabled = true
//    return engine
//}()

class YoutubeModel: Any {
    var title:String?
    var chanel:String?
    var detail:String?
    var thumbnail:String?
    var videoId:String?
    var duration:String?
    

    convenience init(title aTitle:String, chanel aChanel:String, detail aDetail:String, thumbnail aThumbnail:String, videoId aVideoId:String, duration aDuration:String) {
        self.init()
        self.title = aTitle;
        self.chanel = aChanel;
        self.detail = aDetail;
        self.thumbnail = aThumbnail;
        self.videoId = aVideoId;
        self.duration = aDuration
    }
    
}


class YoutubeSearchViewController: UIViewController {
    
//    weak var rootControllerDelegate: YTSCViewControllerDelegate?

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    // Array to store all the desired values dictionaries
    var videosArray: Array<YoutubeModel> = []
    var duration = ""

    private var isLoading: Bool = false {
        didSet{
            loadingView.isHidden = !isLoading
            loadingIndicator.isHidden = !isLoading
            tableView.isHidden = isLoading
            if isLoading {
                loadingIndicator.startAnimating()
                contentInfoLabel.text = "Loading"
            } else {
                loadingIndicator.stopAnimating()
            }
        }
    }
    @IBOutlet weak var contentInfoLabel: UILabel!
    
    // Set up a network session
    let session = URLSession.shared
    
    // ReST GET static String parts
    let BASE_URL: String = "https://www.googleapis.com/youtube/v3/"
    let SEARCH_VIDEO: String = "search?part=snippet&maxResults=50&q="
    let VIDEO_TYPE: String = "&type=video&key="
    let API_KEY: String = "AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Youtube"
        configView()
        isLoading = true
        getVideoList("isabel palacios")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func configView() {
        searchBar.delegate = self;
        tableView.register(UINib.init(nibName: "YoutubeCell", bundle: nil), forCellReuseIdentifier: "youtube_cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        loadingView.isHidden = false
        loadingIndicator.isHidden = true
        contentInfoLabel.text = "Enter keyword to search"
    }

    internal func searchYoutubeWithKey(_ keyword: String?) -> Void {
        if (keyword == nil) {
            return;
        }
        isLoading = true
        if keyword == "" {
            getVideoList("isabel palacios")
        } else {
            getVideoList(keyword!)
        }
    }
    
    
    func getVideoList(_ keyword: String) {
        
        let methodArguments: [String: AnyObject] = [
            "query": keyword as AnyObject
        ]
        
        // Format the search string (video title) for http request
        let videoTitle: String = escapedParameters(methodArguments)
        
        // Make the query url
        let searchVideoByTitle = BASE_URL + SEARCH_VIDEO + videoTitle + VIDEO_TYPE + API_KEY
        print(videoTitle)
        print(searchVideoByTitle)
        if let url = URL(string: searchVideoByTitle) {
            let request = URLRequest(url: url)
            // Initialise the task for getting the data
            initialiseTaskForGettingData(request, element: "items")
        }
    }
    
    
    func initialiseTaskForGettingData(_ request: URLRequest, element: String) {
        let task = session.dataTask(with: request, completionHandler: {(data, HTTPStatusCode, error) in
            if error != nil {
                print(error as Any)
                return
            }
            else {
                let resultDict: [String: AnyObject]!
                do {
                    resultDict = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! [String: AnyObject]
                    if let itemsArray = (resultDict as AnyObject).value(forKey: element) as? NSArray {
                        self.videosArray.removeAll()
                        print(itemsArray)
                        for index in 0..<itemsArray.count {
                            self.videosArray.append(self.unwrapYoutubeJson(arrayToBeUnwrapped: itemsArray, index: index))
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.isLoading = false
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        })
        task.resume()
    }
    
    func unwrapYoutubeJson(arrayToBeUnwrapped: NSArray, index: Int) -> YoutubeModel{
        
        let firstItemDict = arrayToBeUnwrapped[index] as! [String: AnyObject]
        let snippetDict = firstItemDict["snippet"] as! [String: AnyObject]
        var desiredValuesDict = [String: AnyObject]()
        desiredValuesDict["title"] = snippetDict["title"]
        desiredValuesDict["description"] = snippetDict["description"]
        let thumbnailDict: [String: AnyObject]
        thumbnailDict = snippetDict["thumbnails"] as! [String: AnyObject]
        let defaultThumbnailDict = thumbnailDict["high"] as! [String: AnyObject]
        desiredValuesDict["thumbnail"] = defaultThumbnailDict["url"]
        let idDict = firstItemDict["id"] as! [String: AnyObject]
        desiredValuesDict["videoId"] = idDict["videoId"]
//        var youtubeModel = YoutubeModel()
//        DispatchQueue.main.async {
            let youtubeModel = YoutubeModel(title: (snippetDict["title"] as? String) ?? "",
                                        chanel: (snippetDict["channelTitle"] as? String) ?? "",
                                        detail: (snippetDict["description"] as? String) ?? "",
                                        thumbnail: (defaultThumbnailDict["url"] as? String) ?? "",
                                        videoId: (idDict["videoId"] as? String) ?? "",
                                        duration: "")

//        }
        return youtubeModel
    }

    func getDuration(videoID: String) -> String {
        let session = URLSession.shared
        
        let contentDetailsUrl = "https://www.googleapis.com/youtube/v3/videos?id=\(videoID)&part=contentDetails&key=AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"
        
        let request = URLRequest(url: URL(string: contentDetailsUrl)!)
        
        let task = session.dataTask(with: request, completionHandler: {(data, HTTPStatusCode, error) in
            if error != nil {
                print(error as Any)
                return
            }
            else {
                let resultDict: [String: AnyObject]!
                do {
                    resultDict = try JSONSerialization.jsonObject(with: data! as Data, options: .allowFragments) as! [String: AnyObject]
                    if let itemsArray = (resultDict as AnyObject).value(forKey: "items") as? NSArray {
                        print(itemsArray)
                        for index in 0..<itemsArray.count {
                            //                            self.videosArray.append(self.unwrapYoutubeJson(arrayToBeUnwrapped: itemsArray, index: index))
                            let firstItemDict = itemsArray[index] as! [String: AnyObject]
                            let contentDetailsDict = firstItemDict["contentDetails"] as! [String: AnyObject]
                            var desiredValuesDict = [String: AnyObject]()
                            desiredValuesDict["duration"] = contentDetailsDict["duration"]
                            
                            self.duration = contentDetailsDict["duration"] as! String
                            print(self.duration)
                            
                        }
                    }
                    
                } catch let jsonError {
                    print(jsonError)
                }
            }
        })
        task.resume()
        
        return duration
        
    }

    // Helper function: Given a dictionary of parameters, convert to a string for a url
    func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        var urlVars = [String]()
        for (key, value) in parameters {
            let stringValue = "\(value)"
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            urlVars += ["\(escapedValue!)"]
        }
        return (!urlVars.isEmpty ? "" : "") + urlVars.joined(separator: "&")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShareYoutubeVideo" {
            guard let destinationViewController = segue.destination as? YoutubeCreateShareViewController else { return }
            guard let model = sender as? YoutubeModel else { return }
            destinationViewController.model = model
        }
    }
}

extension YoutubeSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosArray.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "youtube_cell", for: indexPath) as! YoutubeCell
        cell.model = videosArray[indexPath.row]
        DispatchQueue.main.async {
            cell.duration.text = self.getDuration(videoID: (cell.model?.videoId)!).getYoutubeFormattedDuration()
        }
        
        return cell
    }
}


extension YoutubeSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 284;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = videosArray[indexPath.row]
        self.performSegue(withIdentifier: "toShareYoutubeVideo", sender: model)
    }
}

extension YoutubeSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        searchBar.endEditing(true)
        searchYoutubeWithKey(searchBar.text!)
    }
}
