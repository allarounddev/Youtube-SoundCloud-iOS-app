//
//  SoundCloudCreateShareViewController.swift
//  Streamini
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class SoundCloudCreateShareViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var titleView: UITextView!
    @IBOutlet weak var priceView: UITextField!
    @IBOutlet weak var playerView: YTPlayerView!
    @IBOutlet weak var locationView: UILabel!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var track:Track?
    var stream: Stream?
    var timer: Timer?
    let messenger           = MessengerFactory.getMessenger("pubnub")!
    let kTimerInterval      = TimeInterval(15.0)
    var textViewHandler: GrowingTextViewHandler?
    var playListArray: NSArray!

    var videoID: String?
    var avatarStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()

    }

    func configureView() {
        
        // Configure NameTextView
        var nameTextViewFrame = titleView.frame
        nameTextViewFrame.size.height = 36.0
        titleView.frame = nameTextViewFrame
        
        // Set placeholder for NameTextView
        titleView.tintColor = UIColor.white
        let placeholderText = NSLocalizedString("stream_name_placeholder", comment: "")
        applyPlaceholderStyle(titleView, placeholderText: placeholderText)
        
        // placeholder for price field
        priceView.placeholder = NSLocalizedString("price", comment: "")
        
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        guard let videoId = model?.videoId else { return }
//        playerView.load(withVideoId: videoId, playerVars: ["playsinline":1])
    }
    
    
    @IBAction func didTouchPublishButton(_ sender: Any) {
        loadingIndicator.startAnimating()
        
        let data = NSMutableDictionary(objects: [titleView.text!, priceView.text!], forKeys: ["title" as NSCopying, "price" as NSCopying])
//        let SCUrlString = track?.streamURL?.absoluteString
        
        var SCUrlString: String?
        
        if self.videoID == nil {
            SCUrlString = URL(string: "https://api.soundcloud.com/tracks/\(track?.identifier ?? 0)")?.absoluteString
        } else {
            SCUrlString = self.videoID
        }


        print(SCUrlString!)
        if let pm = LocationManager.shared.currentPlacemark {
            data["lon"]  = pm.location!.coordinate.longitude
            data["lat"]  = pm.location!.coordinate.latitude
            data["city"] = pm.locality
        }
        data["videotype"] = "scmusic"
        data["extras"] = "\(SCUrlString ?? "")"
        data["private"] = 0
        StreamConnector().create(data, success: createStreamSuccess, failure: createStreamFailure)
    }
    
    @IBAction func didTouchCloseButton(_ sender: Any) {
        LocationManager.shared.stopMonitoringLocation()
        self.priceView.resignFirstResponder()
        
        close()
    }
    
    @IBAction func didTouchPlayMusic(_ sender: Any) {
        
        var mediaUrl: URL?
        
        if self.videoID == nil {
            mediaUrl = URL(string: "https://api.soundcloud.com/tracks/\(track?.identifier ?? 0)/stream?client_id=\(Soundcloud.clientIdentifier!)")
        } else {
            mediaUrl = URL(string: "\(self.videoID!)/stream?client_id=\(Soundcloud.clientIdentifier!)")
            print(mediaUrl)
        }

//        let mediaUrl = track?.streamURL
        
        if mediaUrl != nil {
            print("selected")
            let playerViewController = AVPlayerViewController()
            let player = AVPlayer(url: mediaUrl!)
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                playerViewController.player!.play()
            }
        }

    }
    
    @IBAction func didTouchAddToPlayList(_ sender: Any) {
        loadingIndicator.startAnimating()
        
        let data = NSMutableDictionary(objects: [titleView.text!, priceView.text!], forKeys: ["title" as NSCopying, "price" as NSCopying])
        //        let SCUrlString = track?.streamURL?.absoluteString
        
        var SCUrlString: String?
        
        if self.videoID == nil {
            SCUrlString = URL(string: "https://api.soundcloud.com/tracks/\(track?.identifier ?? 0)")?.absoluteString
        } else {
            SCUrlString = self.videoID
        }
        
        
        print(SCUrlString!)
        if let pm = LocationManager.shared.currentPlacemark {
            data["lon"]  = pm.location!.coordinate.longitude
            data["lat"]  = pm.location!.coordinate.latitude
            data["city"] = pm.locality
        }
        data["videotype"] = "scmusic"
        data["extras"] = "\(SCUrlString ?? "")"
        data["isplaylist"] = true
        data["private"] = 0
        StreamConnector().create(data, success: createStreamSuccess, failure: createStreamFailure)

    }

    func createStreamSuccess(_ stream: Stream) {
        self.stream = stream
        loadingIndicator.stopAnimating()
        
        var url: URL?
        
        if AmazonTool.isAmazonSupported() {
            
            if self.videoID == nil {
                url = track?.artworkImageURL.highURL
            } else {
                url = URL(string: self.avatarStr!)
            }

            
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    let screenshot = UIImage(data: data!)
                    let filename = "\(UserContainer.shared.logged().id)-\(stream.id)-screenshot.jpg"
                    AmazonTool.shared.uploadImage(screenshot!, name: filename)
                }
            }
        }
        
        LocationManager.shared.stopMonitoringLocation()
        let twitter = SocialToolFactory.getSocial("Twitter")!
        let twurl = "\(Config.shared.twitter().tweetURL)/\(stream.streamHash)/\(stream.id)"
        twitter.post(UserContainer.shared.logged().name, live: URL(string: twurl)!)
        let connector = StreamConnector()
        connector.close(self.stream!.id, success: closeStreamSuccess, failure: closeStreamFailure)
        
        close()
    }
    
    func closeStreamSuccess() {
        closeStreamSilentSuccess()
//        self.navigationController!.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
    func closeStreamSilentSuccess() {
        //        timer!.invalidate()
        messenger.send(Message.disconnected(), streamId: stream!.id)
        messenger.send(Message.closed(), streamId: stream!.id)
        messenger.disconnect(stream!.id)
        //        camera!.stop()
    }
    
    func closeStreamFailure(_ error: NSError) {
        handleError(error)
    }
    
    
    func createStreamFailure(_ error: NSError) {
        loadingIndicator.stopAnimating()
        
        print("\(error.localizedDescription)")
    }
    
    
    func close() {
//        let childs = self.navigationController?.childViewControllers
//        guard let lastVc = childs?.last else { return }
//        self.navigationController?.setViewControllers([lastVc], animated: false)
//        lastVc.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)

    }
    
    // MARK: - TextViewDelegate
    
    func moveCursorToStart(_ textView: UITextView)
    {
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor(white: 1.0, alpha: 0.5)
        {
            // move cursor to start
            moveCursorToStart(textView)
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textView.text = textView.text.handleEmoji()
        self.textViewHandler!.resizeTextView(withAnimation: true)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var updatedText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        updatedText = updatedText.handleEmoji()
        
        // Seach for new lines. Don't alow user to insert new lines in stream title
        let newLineRange: Range? = updatedText.rangeOfCharacter(from: CharacterSet.newlines)
        
        let shouldEdit = (updatedText.count < 80) && (newLineRange == nil)
        if !shouldEdit {
            return false
        }
        
        if updatedText.isEmpty {
            let placeholderText = NSLocalizedString("stream_name_placeholder", comment: "")
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
        
        // Remove placeholder text if it is shown
        if titleView.textColor == UIColor(white: 1.0, alpha: 0.5) && !text.isEmpty {
            titleView.text = ""
            applyNonPlaceholderStyle(textView)
            return true
        }
        
        return true
    }
    
    func applyPlaceholderStyle(_ aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor(white: 1.0, alpha: 0.5)
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.white
        aTextview.alpha = 1.0
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
