//
//  LiveStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class LiveStreamViewController: BaseViewController, UserSelecting, UserStatusDelegate, UIAlertViewDelegate {
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet weak var closeButton: SensibleButton!
    @IBOutlet weak var rotateButton: SensibleButton!
    @IBOutlet weak var infoButton: SensibleButton!
    @IBOutlet weak var eyeButton: SensibleButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var likeView: UIView!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!     // 400 by default
    @IBOutlet weak var viewersCollectionViewHeight: NSLayoutConstraint! // 50 pt default
    @IBOutlet weak var viewersCollectionView: UICollectionView!
    
    var commentsDataSource  = CommentsDataSource()
    var viewersDataSource   = ViewersDataSource()
    var viewers: UInt       = 0
    let animator            = HeartBounceAnimator()
    let messenger           = MessengerFactory.getMessenger("pubnub")!
    let kTimerInterval      = TimeInterval(15.0)    
    var infoViewDelegate: DefaultInfoViewDelegate?
    var camera: Camera?    
    var stream: Stream?
    
    var timer: Timer?
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        let connector = StreamConnector()
        connector.close(stream!.id, success: closeStreamSuccess, failure: closeStreamFailure)
    }
    
    @IBAction func rotateButtonPressed(_ sender: AnyObject) {
        camera!.switchCameraDirection()
        if camera!.session!.cameraState == .front {
            previewView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        } else {
            previewView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        infoView.show(true)
    }
    
    @IBAction func viewersButtonPressed(_ sender: AnyObject) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            // If viewers collection view is opened - close it
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.view.layoutIfNeeded()
            })
        } else {
            // If viewers collection view is closed - get viewers list from server 
            // and open collection view
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), success: viewersSuccess, failure: viewersFailure)
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 58.0
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
                    //self.viewersCollectionView.reloadData()
            }) 
        }
    }
    
    // MARK: - Viewers counter
    
    func updateCounter() {
        StreamConnector().get(stream!.id, success: getStreamSuccess, failure: getStreamFailure)
    }
    
    // MARK: - Network responses
    
    func chatMessageReceived(_ message: Message) {        
        if let messageController = MessageController.getMessageControllerForOwner(message.type, viewController: self) {
            messageController.handle(message)
        }
    }
    
    func getStreamSuccess(_ stream: Stream) {
        self.stream = stream
        infoViewDelegate!.stream = stream
        viewersLabel.text = "\(stream.viewers)"
    }
    
    func getStreamFailure(_ error: NSError) {
        handleError(error)
    }
    
    func closeStreamSuccess() {
        closeStreamSilentSuccess()
        self.navigationController!.dismiss(animated: true, completion: nil)
    }
    
    func closeStreamSilentSuccess() {
        timer!.invalidate()
        messenger.send(Message.disconnected(), streamId: stream!.id)
        messenger.send(Message.closed(), streamId: stream!.id)
        messenger.disconnect(stream!.id)
        camera!.stop()
    }
    
    func closeStreamFailure(_ error: NSError) {
        handleError(error)
    }
    
    func viewersSuccess(_ likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = users
        self.viewersCollectionView.reloadData()
        
        /*UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.viewersCollectionViewHeight.constant = 58.0
            self.view.layoutIfNeeded()
            }) { (completed) -> Void in
                
        }*/
    }
    
    func viewersFailure(_ error: NSError) {
        handleError(error)
    }
    
    // MARK: - Handle notifications
    
    @objc func forceClose(_ notification: Notification) {
        StreamConnector().close(stream!.id, success: closeStreamSilentSuccess, failure: closeStreamFailure)
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: self)
    }
    
    // MARK: - UserStatusDelegae
    
    func blockStatusDidChange(_ status: Bool, user: User) {
        if status {
            messenger.send(Message.blocked(user.id), streamId: stream!.id)
        }
    }
    
    func followStatusDidChange(_ status: Bool, user: User) {
    }
    
    // MARK: - Ping
    
    func pingSuccess() {
    }
    
    func pingFailure(_ error: NSError) {
        closeStreamSilentSuccess()
        handleError(error)
        
        if let userInfo = error.userInfo as? [NSObject: NSObject] {
            // modify and assign values as necessary
            if userInfo["code" as NSObject] as? UInt == kUnsuccessfullPing {
                let message = userInfo[NSLocalizedDescriptionKey as NSObject] as! String
                let alertView = UIAlertView.unsuccessfullPingAlert(message, delegate: self)
                alertView.show()
            }
        }
    }
    
    @objc func ping(_ timer: Timer) {
        StreamConnector().ping(stream!.id, success: pingSuccess, failure: pingFailure)
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        StreamConnector().close(stream!.id, success: closeStreamSuccess, failure: closeStreamFailure)
    }
    
    // MARK: - View life cycle
    
    func configureView() {        
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State())
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), for: UIControl.State.highlighted)
        rotateButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State())
        rotateButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), for: UIControl.State.highlighted)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), for: UIControl.State())
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State.highlighted)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), for: UIControl.State())
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State.highlighted)
        
        commentsDataSource.userSelectedDelegate = self
        commentsTableView.delegate = commentsDataSource
        commentsTableView.dataSource = commentsDataSource
        commentsTableView.transform = CGAffineTransform(rotationAngle: CGFloat(-M_PI))
        
        viewersDataSource.userSelectedDelegate = self        
        viewersCollectionView.dataSource = viewersDataSource
        
        infoViewDelegate = DefaultInfoViewDelegate(close: closeButton, info: infoButton, rotate: rotateButton)
        infoViewDelegate!.stream = stream!
        infoView.delegate = infoViewDelegate!
        infoView.userSelectingDelegate = self
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        
        camera!.addPreviewView(previewView)
        
        messenger.connect(stream!.id)
        messenger.receive(chatMessageReceived)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LiveStreamViewController.forceClose(_:)), name: NSNotification.Name(rawValue: "Close/Leave"), object: nil)
        
        self.timer = Timer(timeInterval: kTimerInterval, target: self, selector: #selector(LiveStreamViewController.ping(_:)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private methods
    
    fileprivate func isLastRowFit(_ tableViewHeight: CGFloat) -> Bool {
        let cellsCount = commentsTableView.visibleCells.count-1
        let actualCellsHeight = CGFloat(cellsCount) * commentsTableView.rowHeight
        
        return (actualCellsHeight + commentsTableView.rowHeight) < tableViewHeight
    }
    
    fileprivate func removeCommentAt(_ indexPath: IndexPath) {
        commentsDataSource.removeCommentAt(indexPath.row)
        commentsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }

    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
