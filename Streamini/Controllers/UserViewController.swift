//
//  UserViewController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol UserSelecting: class {
    func userDidSelected(_ user: User)
}

protocol StreamSelecting: class {
    func streamDidSelected(_ stream: Stream)
}

protocol UserStatisticsDelegate: class {
    func recentStreamsDidSelected(_ userId: UInt)
    func followersDidSelected(_ userId: UInt)
    func followingDidSelected(_ userId: UInt)
}

protocol UserStatusDelegate: class {
    func followStatusDidChange(_ status: Bool, user: User)
    func blockStatusDidChange(_ status: Bool, user: User)
}

class UserViewController: BaseViewController, UserHeaderViewDelegate, ProfileDelegate {
    static let animationDuration = 0.2
    
    @IBOutlet weak var userHeaderView: UserHeaderView!
    @IBOutlet weak var recentCountLabel: UILabel!
    @IBOutlet weak var recentLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewHeight: NSLayoutConstraint!
    
    var user: User?
    var userStatisticsDelegate: UserStatisticsDelegate?
    var userStatusDelegate: UserStatusDelegate?
    
    var originalViewFrame     = CGRect.zero
    var originalFormSheetSize = CGSize.zero
    
    // MARK: - Actions
    
    @IBAction func recentButtonPressed(_ sender: AnyObject) {
        expandFormSheet()
        userHeaderView.showCompactMode()
        
        if let del = userStatisticsDelegate {
            del.recentStreamsDidSelected(user!.id)
        }
    }
    
    @IBAction func followersButtonPressed(_ sender: AnyObject) {
        expandFormSheet()
        userHeaderView.showCompactMode()
        
        if let del = userStatisticsDelegate {
            del.followersDidSelected(user!.id)
        }
    }
    
    @IBAction func followingButtonPressed(_ sender: AnyObject) {
        expandFormSheet()        
        userHeaderView.showCompactMode()
        
        if let del = userStatisticsDelegate {
            del.followingDidSelected(user!.id)
        }
    }
    
    @IBAction func followButtonPressed(_ sender: AnyObject) {
        followButton.isEnabled = false
        if user!.isFollowed {
            SocialConnector().unfollow(user!.id, success: unfollowSuccess, failure: unfollowFailure)
        } else {
            SocialConnector().follow(user!.id, success: followSuccess, failure: followFailure)
        }
    }
    
    @IBAction func blockButtonPressed(_ sender: AnyObject) {
        blockButton.isEnabled = false
        if user!.isBlocked {
            SocialConnector().unblock(user!.id, success: unblockSuccess, failure: unblockFailure)
        } else {
            SocialConnector().block(user!.id, success: blockSuccess, failure: blockFailure)
        }
    }
    
    // MARK: - ProfileDelegate
    
    func reload() {
        update(user!.id)
    }
    
    func close() {
        self.closeButtonPressed(self)
    }
    
    // MARK: - UserHeaderViewDelegate
    
    func closeButtonPressed(_ sender: AnyObject) {
        self.mz_dismissFormSheetController(animated: true, completionHandler: { (formSheetController) -> Void in
            self.changeVisibility(hide: true, animated: false)
        })
    }
    
    func usernameLabelPressed() {
        fallFormSheet()
        userHeaderView.showFullMode()
    }
    
    func descriptionWillStartEdit() {
    }
    
    // MARK: - View life cycle
    
    func configureView() {
        changeVisibility(hide: true, animated: false)
        userHeaderView.delegate = self
        
        let recentLabelText = NSLocalizedString("user_card_recent", comment: "")
        recentLabel.text = recentLabelText
        
        let followersLabelText = NSLocalizedString("user_card_followers", comment: "")
        followersLabel.text = followersLabelText
        
        let followingLabelText = NSLocalizedString("user_card_following", comment: "")
        followingLabel.text = followingLabelText
        
        followButton.isHidden = UserContainer.shared.logged().id == user!.id
        blockButton.isHidden  = UserContainer.shared.logged().id == user!.id
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureView()
        update(user!.id)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sid = segue.identifier {
            if sid == "UserToLinkedUsers" {
                let controller = segue.destination as! LinkedUsersViewController
                controller.profileDelegate = self
                self.userStatisticsDelegate = controller
            }
        }
    }
    
    // MARK: - Memory management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Network communication
    
    func followSuccess() {
        followButton.isEnabled = true
        user!.isFollowed = true
        let buttonTitle = NSLocalizedString("user_card_unfollow", comment: "")
        followButton.setTitle(buttonTitle, for: UIControl.State())
        
        if let delegate = userStatusDelegate {
            delegate.followStatusDidChange(true, user: user!)
        }
        
        update(user!.id)
    }
    
    func followFailure(_ error: NSError) {
        handleError(error)
        followButton.isEnabled = true
    }
    
    func unfollowSuccess() {
        followButton.isEnabled = true
        user!.isFollowed = false
        let buttonTitle = NSLocalizedString("user_card_follow", comment: "")
        followButton.setTitle(buttonTitle, for: UIControl.State())
        
        if let delegate = userStatusDelegate {
            delegate.followStatusDidChange(false, user: user!)
        }
        
        update(user!.id)
    }
    
    func unfollowFailure(_ error: NSError) {
        handleError(error)
        followButton.isEnabled = true
    }
    
    func blockSuccess() {
        blockButton.isEnabled = true
        user!.isBlocked = true
        let buttonTitle = NSLocalizedString("user_card_unblock", comment: "")
        blockButton.setTitle(buttonTitle, for: UIControl.State())
        
        if let delegate = userStatusDelegate {
            delegate.blockStatusDidChange(true, user: user!)
        }
    }
    
    func blockFailure(_ error: NSError) {
        handleError(error)
        blockButton.isEnabled = true
    }
    
    func unblockSuccess() {
        blockButton.isEnabled = true
        user!.isBlocked = false
        let buttonTitle = NSLocalizedString("user_card_block", comment: "")
        blockButton.setTitle(buttonTitle, for: UIControl.State())
        
        if let delegate = userStatusDelegate {
            delegate.blockStatusDidChange(false, user: user!)
        }
    }
    
    func unblockFailure(_ error: NSError) {
        handleError(error)
        blockButton.isEnabled = true
    }
    
    // MARK: - Update user
    
    func getUserSuccess(_ user: User) {
        self.user = user
        
        userHeaderView.update(user)
        recentCountLabel.text       = "\(user.recent)"
        followersCountLabel.text    = "\(user.followers)"
        followingCountLabel.text    = "\(user.following)"
        
        if user.isFollowed {
            let buttonTitle = NSLocalizedString("user_card_unfollow", comment: "")
            followButton.setTitle(buttonTitle, for: UIControl.State())
        } else {
            let buttonTitle = NSLocalizedString("user_card_follow", comment: "")
            followButton.setTitle(buttonTitle, for: UIControl.State())
        }
        
        if user.isBlocked {
            let buttonTitle = NSLocalizedString("user_card_unblock", comment: "")
            blockButton.setTitle(buttonTitle, for: UIControl.State())
        } else {
            let buttonTitle = NSLocalizedString("user_card_block", comment: "")
            blockButton.setTitle(buttonTitle, for: UIControl.State())
        }
        
        activityIndicator.stopAnimating()
        changeVisibility(hide: false, animated: true)        
    }
    
    func getUserFailure(_ error: NSError) {
        handleError(error)
        activityIndicator.stopAnimating()
    }
    
    func update(_ userId: UInt) {
        activityIndicator.startAnimating()
        UserConnector().get(userId, success: getUserSuccess, failure: getUserFailure)
    }
    
    // MARK: - Private methods
    
    fileprivate func expandFormSheet() {
        let formSheetController = self.formSheetController!
        
        // calculate new size
        let size = formSheetController.presentedFormSheetSize
        let height = UIScreen.main.bounds.height - 10.0 // new height
        formSheetController.presentedFormSheetSize = CGSize(width: size.width, height: height)
        
        // animatable update formsheet size
        UIView.animate(withDuration: UserViewController.animationDuration, animations: { () -> Void in
            let x       = self.view.frame.origin.x
            let y       = CGFloat(25.0)
            let width   = self.view.frame.size.width
            self.view.frame = CGRect(x: x, y: y, width: width, height: height)
            self.containerViewHeight.constant = height - UserHeaderViewHeight.compact.rawValue - 102.0
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func fallFormSheet() {
        // animatable update formsheet size
        UIView.animate(withDuration: UserViewController.animationDuration, animations: { () -> Void in
            self.formSheetController!.presentedFormSheetSize = self.originalFormSheetSize
            self.view.frame = self.originalViewFrame
            self.containerViewHeight.constant = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func changeVisibility(hide: Bool, animated: Bool) {
        let alpha: CGFloat = hide ? 0.0 : 1.0
        let duration = (animated) ? 0.3 : 0.0
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.userHeaderView.alpha       = alpha
            self.recentCountLabel.alpha     = alpha
            self.recentLabel.alpha          = alpha
            self.followersCountLabel.alpha  = alpha
            self.followersLabel.alpha       = alpha
            self.followingCountLabel.alpha  = alpha
            self.followingLabel.alpha       = alpha
            self.followButton.alpha         = alpha
            self.blockButton.alpha          = alpha
        })
    }
}
