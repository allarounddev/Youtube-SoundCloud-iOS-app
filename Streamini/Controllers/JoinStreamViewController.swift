//
//  JoinStreamViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 14/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class JoinStreamViewController: BaseViewController, UITextFieldDelegate, UITextViewDelegate, UITableViewDelegate, UIAlertViewDelegate,
UIActionSheetDelegate, SelectFollowersDelegate, ReplayViewDelegate, UserSelecting, CollectionViewPullDelegate, PayPalPaymentDelegate, YTPlayerViewDelegate {
    
    var payPalConfig = PayPalConfiguration()
    
    @IBOutlet weak var infoView: InfoView!
    @IBOutlet weak var replayView: ReplayView!
    @IBOutlet weak var YTPlayer: YTPlayerView!
    @IBOutlet weak var SCMusicImageView: UIImageView!
    
    @IBOutlet weak var closeButton: SensibleButton!
    @IBOutlet weak var infoButton: SensibleButton!
    @IBOutlet weak var eyeButton: SensibleButton!
    
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var likeView: UIView!
    
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewersLabelBottomConstraint: NSLayoutConstraint!    // 8 by default
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var messageTextViewRightConstraint: NSLayoutConstraint! // 43 by default
    @IBOutlet weak var messageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageViewBottomConstraint: NSLayoutConstraint!     // 8 by default
    
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsTableViewHeight: NSLayoutConstraint!     // 360 by default
    @IBOutlet weak var viewersCollectionViewHeight: NSLayoutConstraint! // 58 by default
    @IBOutlet weak var viewersCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var likesViewBottom: NSLayoutConstraint! // 16
    @IBOutlet weak var viewersBottom: NSLayoutConstraint! // 16
    @IBOutlet weak var replaysBottom: NSLayoutConstraint! // 16
    
    var commentsDataSource  = CommentsDataSource()
    var viewersDataSource   = ViewersDataSource()
    var viewersDelegate     = ViewersDelegate()
    let animator            = HeartBounceAnimator()
    var likes: UInt         = 0
    var isRecent            = false
    var messenger:Messenger?
    var keyboardHandler: JoinStreamKeyboardHandler?
    var infoViewDelegate: JoinInfoViewDelegate?
    var streamPlayer: StreamPlayer?
    var scMusicPlayer: SCMusicPlayer?
    var youtubePlayer: YouTubePlayer?
    var stream: Stream?
    var textViewHandler: GrowingTextViewHandler?
    
    var page: UInt = 0
    
    weak var delegate: MainViewControllerDelegate?
    
    // PayPalConfiguration
    var environment:String = PayPalEnvironmentProduction {
        willSet(newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment: newEnvironment)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        closeButton.isEnabled = false
        
        if let del = delegate {
            del.streamListReload()
        }
        
        if (streamPlayer != nil) || (youtubePlayer != nil) || (scMusicPlayer != nil) {
            StreamConnector().leave(stream!.id, likes: likes, success: leaveSuccess, failure: leaveFailure)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func closeStream() {
        if (streamPlayer != nil) || (youtubePlayer != nil) || (scMusicPlayer != nil) {
            StreamConnector().leave(stream!.id, likes: likes, success: leaveWithAlertSuccess, failure: leaveFailure)
        } else {
            UIAlertView.streamClosedAlert(nil).show()
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        infoView.show(false)
    }
    
    @IBAction func viewersButtonPressed(_ sender: AnyObject) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            self.viewersDataSource.viewers = []
            self.viewersCollectionView.reloadData()
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
            }, completion: { (finished) -> Void in
                
            })
            
        } else {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 58.0
                self.likesViewBottom.constant   = 58.0 + 16.0
                self.viewersBottom.constant     = 58.0 + 16.0
                self.replaysBottom.constant     = 58.0 + 16.0
                
                self.view.layoutIfNeeded()
            })
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), success: viewersSuccess, failure: failureWithoutAction)
        }
    }
    
    @IBAction func authorImageViewPressed(_ sender: AnyObject) {
        self.showUserInfo(stream!.user, userStatusDelegate: nil)
    }
    
    @IBAction func tapGesturePerformed(_ sender: AnyObject) {
        if messageTextView.isFirstResponder {
            messageTextView.resignFirstResponder()
        } else {
            
                self.likes = self.likes+1
                self.messenger!.send(Message.like(), streamId: self.stream!.id)
            
        }
    }
    
    @IBAction func closeKeyboardButtonPerformed(_ sender: AnyObject) {
        messageTextView.resignFirstResponder()
    }
    
    // MARK: - ReplayViewDelegate
    
    func replayViewWillBeShown(_ replayView: ReplayView) {
        replayView.update(stream!)
        closeButton.isHidden      = true
        infoButton.isHidden       = true
        messageTextView.isHidden  = true
        messageTextView.resignFirstResponder()
    }
    
    func replayViewStreamDidEnd(_ replayView: ReplayView) {
            StreamConnector().leave(stream!.id, likes: 0, success: leaveAnother, failure: leaveFailure)
    }
    
    func replayViewWillBeHidden(_ replayView: ReplayView) {
        closeButton.isHidden      = false
        infoButton.isHidden       = false
        messageTextView.isHidden  = false
    }
    
    func replayViewPlayButtonPressed(_ replayView: ReplayView) {
        if self.viewersCollectionViewHeight.constant == 58.0 {
            viewersButtonPressed(eyeButton)
        }
            StreamConnector().join(stream!.id, success: joinSuccess, failure: joinFailure)
    }
    
    func replayViewCloseButtonPressed(_ replayView: ReplayView) {
        if let player = streamPlayer {
            player.reset()
        }
        self.dismiss(animated: true, completion: nil)
    }
        
    func replayViewViewersButtonPressed(_ replayView: ReplayView) {
        
        if self.viewersCollectionViewHeight.constant == 58.0 && replayView.viewersIsShown {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
            }) 
        } else {
            page = 0
            StreamConnector().viewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), success: viewersSuccess, failure: failureWithoutAction)
        }
    }
    
    func replayViewReplaysButtonPressed(_ replayView: ReplayView) {
        if self.viewersCollectionViewHeight.constant == 58.0 && replayView.replaysIsShown {
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.viewersCollectionViewHeight.constant = 0.0
                self.likesViewBottom.constant   = 16.0
                self.viewersBottom.constant     = 16.0
                self.replaysBottom.constant     = 16.0
                
                self.view.layoutIfNeeded()
                }, completion: { (completed) -> Void in
            }) 
        } else {
            page = 0
            StreamConnector().replayViewers(NSDictionary(object: stream!.id, forKey: "streamId" as NSCopying), success: viewersSuccess, failure: failureWithoutAction)
        }
    }
    
    // MARK: - SelectFollowersDelegate
    
    func followersDidSelected(_ users: [User]) {
        let usersId = users.map({ $0.id })
        StreamConnector().share(stream!.id, usersId: usersId, success: successWithoutAction, failure: failureWithoutAction)
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            StreamConnector().share(stream!.id, usersId: nil, success: successWithoutAction, failure: failureWithoutAction)
        }
        if buttonIndex == 2 {
            self.performSegue(withIdentifier: "JoinToFollowers", sender: self)
        }
    }
    
    // MARK: - UIAlertViewDelegate
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            StreamConnector().report(stream!.id, success: successWithoutAction, failure: failureWithoutAction)
        }
    }
    
    // MARK: - Update counter
    
    func updateCounter() {
        StreamConnector().get(stream!.id, success: getStreamSuccess, failure: failureWithoutAction)
    }
    
    // MARK: - Block Stream
    
    func blockStream(_ userId: UInt) {
        if userId == UserContainer.shared.logged().id {
            UIAlertView.userBlockedAlert().show()
            if (streamPlayer != nil) || (youtubePlayer != nil) || (scMusicPlayer != nil) {
                StreamConnector().leave(stream!.id, likes: likes, success: leaveSuccess, failure: leaveFailure)
            }
        }
    }
    
    // MARK: - Network Responses
    
    func successWithoutAction() {
    }
    
    func failureWithoutAction(_ error: NSError) {
        handleError(error)
    }
    
    func viewersSuccess(_ likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = users
        
        self.viewersCollectionView.reloadData()
        
        
    }
    
    func moreViewersSuccess(_ likes: UInt, viewers: UInt, users: [User]) {
        viewersDataSource.viewers = viewersDataSource.viewers + users
        self.viewersCollectionView.reloadData()
    }
    
    func chatMessageReceived(_ message: Message) {
        if let messageController = MessageController.getMessageControllerForJoin(message.type, viewController: self) {
            messageController.handle(message)
        }
    }
    
    func joinSuccess() {
        // Play stream
        if !isRecent {
            streamPlayer = StreamPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator)
            self.streamPlayer!.delegate = DefaultStreamPlayerDelegate(isRecent: isRecent, replayView: replayView)
        } else {
            if stream?.videotype == "youtube"{
                youtubePlayer!.play()
            } else if stream?.videotype == "scmusic" {
                scMusicPlayer!.play()
            } else {
                streamPlayer!.play()
            }
            replayView.hide(true)
            infoButton.isHidden       = false
            messageTextView.isHidden  = false
        }
        
        messenger = MessengerFactory.getMessenger("pubnub")!
        messenger!.connect(stream!.id)
        messenger!.receive(chatMessageReceived)
        messenger!.send(Message.connected(), streamId: stream!.id)
    }
    
    func joinFailure(_ error: NSError) {
        self.activityIndicator.stopAnimating()
        handleError(error)
        
        if let userInfo = error.userInfo as? [NSObject: NSObject] {
            // modify and assign values as necessary
            if userInfo["code" as NSObject] as? UInt == kUserBlocked {
                UIAlertView.userBlockedAlert().show()
                self.dismiss(animated: true, completion: nil)
            }
            if userInfo["code" as NSObject] as? UInt == kPaidStream {
                buyAccess()
            }
        } else {
            UIAlertView.failedJoinStreamAlert().show()
        }
    }
    
    func buyAccess()
    {
        let format = NSLocalizedString("buy_access", comment: "")
        let title = String(format:format, stream!.price)
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action: UIAlertAction!) in
            self.doBuy()
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: { (action: UIAlertAction!) in
            // do nothing
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func doBuy()
    {
        //self.performSegueWithIdentifier("Purchase", sender: self)
        checkout(String(format:"%d", stream!.id), amount: NSDecimalNumber(value: stream!.price as Double), desc: stream!.title)
    }
    
    func leaveSuccess() {
        leaveSilentSuccess()
        self.dismiss(animated: true, completion: nil)
    }
    
    func leaveWithAlertSuccess() {
        leaveSilentSuccess()
        UIAlertView.streamClosedAlert(nil).show()
    }
    
    func leaveSilentSuccess() {
        if let mes = messenger {
            mes.send(Message.disconnected(), streamId: stream!.id)
            mes.disconnect(stream!.id)
        }
        likes = 0
        if stream?.videotype == "youtube"{
            youtubePlayer!.stop()
            youtubePlayer = nil
        } else if stream?.videotype == "scmusic"{
            scMusicPlayer!.stop()
            scMusicPlayer = nil
        } else {
            streamPlayer!.stop()
            streamPlayer = nil
        }
    }
    
    func leaveAnother() {
        replayView.update(stream!)
        closeButton.isHidden      = true
        infoButton.isHidden       = true
        messageTextView.isHidden  = true
        messageTextView.resignFirstResponder()

        if let mes = messenger {
            mes.send(Message.disconnected(), streamId: stream!.id)
            mes.disconnect(stream!.id)
        }
        
        likes = 0
        if stream?.videotype == "youtube"{
            youtubePlayer!.stop()
        } else if stream?.videotype == "scmusic"{
            scMusicPlayer!.stop()
//            scMusicPlayer = nil
        } else {
            streamPlayer!.stop()
        }
    }
    
    func leaveFailure(_ error: NSError) {
        handleError(error)
        closeButton.isEnabled = true
    }
    
    func getStreamSuccess(_ stream: Stream) {
        self.stream = stream
        infoViewDelegate!.stream = stream
        viewersLabel.text = "\(stream.tviewers)"
    }
    
    // MARK: - Handle notifications
    
    @objc func forceLeave(_ notification: Notification) {
        if (streamPlayer != nil) || (youtubePlayer != nil || scMusicPlayer != nil) {
            StreamConnector().leave(stream!.id, likes: likes, success: leaveSilentSuccess, failure: leaveFailure)
            if let mes = messenger {
                mes.send(Message.disconnected(), streamId: stream!.id)
                mes.disconnect(stream!.id)
            }            
        }
    }
    
    // MARK: - UserSelecting protocol
    
    func userDidSelected(_ user: User) {
        self.showUserInfo(user, userStatusDelegate: nil)
    }
    
    // MARK: - View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        SCMusicImageView.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(JoinStreamViewController.forceLeave(_:)), name: NSNotification.Name(rawValue: "Close/Leave"), object: nil)
        if !isRecent {
            StreamConnector().join(stream!.id, success: joinSuccess, failure: joinFailure)
        } else {
            print(stream!.id)
            print(stream!.videotype)
            if stream?.videotype == "youtube"{

                YTPlayer.isHidden = false
                previewView.isHidden = true
                YTPlayer.delegate = self
                youtubePlayer = YouTubePlayer(stream: stream!, isRecent: isRecent, view: YTPlayer, indicator: activityIndicator, replayView: replayView)
                self.youtubePlayer!.delegate = YoutubePlayerDelegate(isRecent: isRecent, replayView: replayView)
                
            } else if stream?.videotype == "scmusic"{
                
                YTPlayer.isHidden = true
                previewView.isHidden = false
                SCMusicImageView.isHidden = false
                SCMusicImageView.sd_setImage(with: stream?.urlToStreamImage())
                scMusicPlayer = SCMusicPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator, replayView: replayView)
                self.scMusicPlayer!.delegate = SCmusicPlayerViewDelegate(isRecent: isRecent, replayView: replayView)

                
            } else {
                
                YTPlayer.isHidden = true
                previewView.isHidden = false
                streamPlayer = StreamPlayer(stream: stream!, isRecent: isRecent, view: previewView, indicator: activityIndicator)
                self.streamPlayer!.delegate = DefaultStreamPlayerDelegate(isRecent: isRecent, replayView: replayView)

            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: true)
        keyboardHandler!.register()
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        PayPalMobile.preconnect(withEnvironment: environment)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isRecent {
            messageTextViewRightConstraint.constant = 8.0
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let navController = navigationController {
            navController.setNavigationBarHidden(false, animated: true)
        }
        keyboardHandler!.unregister()
    }
    
    func configureView() {        
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State())
        closeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), for: UIControl.State.highlighted)
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), for: UIControl.State())
        infoButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State.highlighted)
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 0.7), for: UIControl.State())
        eyeButton.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State.highlighted)
        
        commentsDataSource.userSelectedDelegate = self
        commentsTableView.delegate = commentsDataSource
        commentsTableView.dataSource = commentsDataSource
        commentsTableView.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi))

        messageTextView.tintColor = UIColor(white: 1.0, alpha: 1.0)
        var messageTextViewFrame = messageTextView.frame
        messageTextViewFrame.size.height = 39.0
        messageTextView.frame = messageTextViewFrame
        messageTextView.delegate = self
        self.textViewHandler = GrowingTextViewHandler(textView: messageTextView, withHeightConstraint: messageViewHeightConstraint)
        textViewHandler!.updateMinimumNumber(ofLines: 1, andMaximumNumberOfLine: 3)
        textViewHandler!.setText("", withAnimation: false)
        
        viewersDataSource.userSelectedDelegate = self
        viewersDelegate.pullDelegate     = self
        viewersCollectionView.dataSource = viewersDataSource
        viewersCollectionView.delegate   = viewersDelegate
        
        self.replayView.delegate    = self
        self.replayView.hide(false)
        
        infoViewDelegate = JoinInfoViewDelegate(close: closeButton, info: infoButton, alertViewDelegate: self, actionSheetDelegate: self, actionSheetView: self.view)
        infoViewDelegate!.stream = stream
        self.infoView.delegate = infoViewDelegate!
        self.infoView.userSelectingDelegate = self
        
        keyboardHandler = JoinStreamKeyboardHandler(
            view: view,
            messageTextView: messageTextView,
            commentsTableView: commentsTableView,
            commentsTableViewHeight: commentsTableViewHeight,
            viewersCollectionViewHeight: viewersCollectionViewHeight,
            messageViewBottomConstraint: messageViewBottomConstraint,
            messageTextViewRightConstraint: messageTextViewRightConstraint,
            viewersLabelBottomConstraint: viewersLabelBottomConstraint,
            viewersLabel: viewersLabel,
            eyeButton: eyeButton,
            isRecent: isRecent
        )
        
        if isRecent {
            infoButton.isHidden                       = true
            messageTextView.isHidden                  = true
            viewersLabel.isHidden                     = true
            viewersLabel.backgroundColor            = UIColor.red
            eyeButton.isHidden                        = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "JoinToFollowers" {
                let controller = segue.destination as! FollowersViewController
                controller.delegate = self
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                return false
            }
            messenger!.send(Message.create(textView.text), streamId: stream!.id)
            textViewHandler!.setText("", withAnimation: false)
            return false
        }
        let term = (textView.text as NSString).replacingCharacters(in: range, with: text)
        return term.count <= 140
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        messenger!.send(Message.create(textField.text!), streamId: stream!.id)
        textField.text = ""
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
//        textView.text = textView.text.handleEmoji()
        self.textViewHandler!.resizeTextView(withAnimation: true)
    }
    
    // MARK: - CollectionViewPullDelegate
    
    func collectionViewDidBeginPullingLeft(_ collectionView: UIScrollView, offset: CGFloat) {
        page=page+1
        let data = NSDictionary(objects: [stream!.id, page], forKeys: ["streamId" as NSCopying, "p" as NSCopying])
        if replayView.viewersIsShown {
            StreamConnector().viewers(data, success: moreViewersSuccess, failure: failureWithoutAction)
        }
        if replayView.replaysIsShown {
            StreamConnector().replayViewers(data, success: moreViewersSuccess, failure: failureWithoutAction)
        }
    }
    
    // MARK: - Memory management
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkout(_ type: String, amount: NSDecimalNumber, desc: String) {
        let payment = PayPalPayment(amount: amount, currencyCode: "USD", shortDescription: desc, intent: .sale)
        payment.custom = type;
        
        if (payment.processable) {
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            //paymentViewController.navigationBar. = UIColor.whiteColor()
            UINavigationBar.resetCustomAppereance()
            present(paymentViewController!, animated: true, completion: { () -> Void in
                UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
            })
        }
        else {
            
            print("Payment not processalbe: \(payment)")
        }
    }
    
    // PayPalPaymentDelegate
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        paymentViewController.dismiss(animated: true, completion: nil)
        UINavigationBar.setCustomAppereance()
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        
        
        
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
            // send completed confirmaion to your server
            print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
            
            let json = completedPayment.confirmation
            let response = json["response"] as! NSDictionary
            if let id = response["id"] as? String {
                StreamConnector().payment(id, success: self.successPayment, failure: self.failurePayment)
            }
        })
        
        UINavigationBar.setCustomAppereance()
    }
    
    func successPayment() {
        StreamConnector().join(stream!.id, success: joinSuccess, failure: joinFailure)
    }
    
    func failurePayment(_ error: NSError) {
        handleError(error)
        //configureView()
        let alertView = UIAlertView.notAuthorizedAlert(NSLocalizedString("order_fail", comment: ""))
        alertView.show()
    }
}
