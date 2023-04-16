//
//  LiveStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 29/06/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

class CreateStreamViewController: BaseViewController, UITextFieldDelegate, LocationManagerDelegate,
UITextViewDelegate {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var darkPreviewView: UIView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var nameTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var connectingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectingLabel: UILabel!
    @IBOutlet weak var goLiveButtonBottom: NSLayoutConstraint! // 240
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationLabelWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var goLiveButton: UIButton!
//    @IBOutlet weak var goYouTubeButton: UIButton!
    
    var stream: Stream?
    let camera = Camera()
    var keyboardHandler: CreateStreamKeyboardHandler?
    var textViewHandler: GrowingTextViewHandler?
    
    @IBOutlet weak var priceField: UITextField!
    
    // MARK: - View life cycle 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        LocationManager.shared.delegate = self
        LocationManager.shared.startMonitoringLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardHandler!.register()
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.setup(previewView)
        // darkPreviewView.layer.addDarkGradientLayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardHandler!.unregister()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        connectingIndicator.stopAnimating()
        goLiveButton.isHidden = false
    }
    
    
    func configureView() {
        // Configure "go live" button
        let goLiveButtonText = NSLocalizedString("go_live_button", comment: "")
        goLiveButton.setTitle(goLiveButtonText, for: UIControl.State())
        
        // Configure NameTextView
        var nameTextViewFrame = nameTextView.frame
        nameTextViewFrame.size.height = 36.0
        nameTextView.frame = nameTextViewFrame
        
        // GrowingTextViewHandler resizes NameTextView according to input text
        self.textViewHandler = GrowingTextViewHandler(textView: nameTextView, withHeightConstraint: nameTextViewHeightConstraint)
        textViewHandler!.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 6)
        textViewHandler!.setText("", withAnimation: false)
        
        // Set placeholder for NameTextView
        nameTextView.tintColor = UIColor.white
        let placeholderText = NSLocalizedString("stream_name_placeholder", comment: "")
        applyPlaceholderStyle(nameTextView, placeholderText: placeholderText)
        
        // placeholder for price field
        priceField.placeholder = NSLocalizedString("price", comment: "")
        
        // Configure connecting label
        let connectingLabelText = NSLocalizedString("connecting_stream_label", comment: "")
        connectingLabel.text = connectingLabelText
        
        keyboardHandler = CreateStreamKeyboardHandler(view: view, constraint: goLiveButtonBottom)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "CreateStreamToLiveStream" {
                let controller = segue.destination as! LiveStreamViewController
                controller.camera = camera
                controller.stream = stream
            }
        }
    }
    
    // MARK: - Actions
//    @IBAction func youtubeDidTouch(_ sender: Any) {
//        self.performSegue(withIdentifier: "goYoutubeSearch", sender: self);
//    }
//
//    @IBAction func SoundCloudDidTouch(_ sender: Any) {
//        self.performSegue(withIdentifier: "goSoundCloudSearch", sender: self);
//
//    }
//    
//    @IBAction func PlayListBtnClicked(_ sender: Any) {
//        self.performSegue(withIdentifier: "goPlayList", sender: self);
//    }
//    
    
    @IBAction func liveStreamButtonPressed(_ sender: AnyObject) {
        let data = NSMutableDictionary(objects: [nameTextView.text, priceField.text!], forKeys: ["title" as NSCopying, "price" as NSCopying])
        
        if let pm = LocationManager.shared.currentPlacemark {
            data["lon"]  = pm.location!.coordinate.longitude
            data["lat"]  = pm.location!.coordinate.latitude
            data["city"] = pm.locality
        }

        connectingIndicator.startAnimating()
        goLiveButton.isHidden = true
        
        if AmazonTool.isAmazonSupported() {
            StreamConnector().create(data, success: createStreamSuccess, failure: createStreamFailure)
        } else {
            let filename = "screenshot.jpg"
            let screenshotData = camera.captureStillImage()?.jpegData(compressionQuality: 1.0)
            StreamConnector().createWithFile(filename, fileData: screenshotData!, data: data, success: createStreamSuccess, failure: createStreamFailure)
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        LocationManager.shared.stopMonitoringLocation()
        self.nameTextView.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Network responses
    
    func createStreamSuccess(_ stream: Stream) {
        self.stream = stream
        
        LocationManager.shared.stopMonitoringLocation()
        
        camera.start(stream.streamHash, streamId: stream.id)
        
        if AmazonTool.isAmazonSupported() {
            let screenshot = camera.captureStillImage()!
            let filename = "\(UserContainer.shared.logged().id)-\(stream.id)-screenshot.jpg"
            AmazonTool.shared.uploadImage(screenshot, name: filename)
        }
        
        let twitter = SocialToolFactory.getSocial("Twitter")!
        let url = "\(Config.shared.twitter().tweetURL)/\(stream.streamHash)/\(stream.id)"
        twitter.post(UserContainer.shared.logged().name, live: URL(string: url)!)
        
        self.performSegue(withIdentifier: "CreateStreamToLiveStream", sender: self)
    }
    
    func createStreamFailure(_ error: NSError) {
        handleError(error)
        connectingIndicator.stopAnimating()
        goLiveButton.isHidden = false
    }
    
    // MARK: - LocationManagerDelegate
    
    func locationDidChanged(_ currentLocation: CLLocationCoordinate2D?, locality: String) {
        // Set location text
        locationLabel.text = locality
        
        // Set width constraint corresponds to the locality string lenght
        let size = locationLabel.sizeThatFits(locationLabel.bounds.size)
        locationLabelWidthConstraint.constant = size.width + 10
        locationLabel.backgroundColor = UIColor.white
        self.view.layoutIfNeeded()
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
        if nameTextView.textColor == UIColor(white: 1.0, alpha: 0.5) && !text.isEmpty {
            nameTextView.text = ""
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
    
    deinit {
        camera.stop()
    }
    
}
