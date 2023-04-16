//
//  UserHeaderView.swift
// Streamini
//
//  Created by Vasily Evreinov on 06/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

enum UserHeaderViewHeight: CGFloat {
    case compact    = 55.0
    case full       = 175.0
}

protocol UserHeaderViewDelegate: class {
    func closeButtonPressed(_ sender: AnyObject)
    func usernameLabelPressed()
    func descriptionWillStartEdit()
}

class UserHeaderView: UIView, UITextViewDelegate {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var topTapableView: UIView!
    @IBOutlet weak var likeIcon: UIImageView!
    @IBOutlet weak var likeCountLabel: UILabel!
    @IBOutlet weak var liveLabel: UILabel!
    @IBOutlet weak var userDescriptionLabel: UILabel!
    @IBOutlet weak var userDescriptionTextView: UITextView!
    
    @IBOutlet weak var usernameLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var usernameLabelLeft: NSLayoutConstraint!
    @IBOutlet weak var height: NSLayoutConstraint!
    
    var topTapGestureRecognizer: UITapGestureRecognizer?
    
    var isFullMode = true
    weak var delegate: UserHeaderViewDelegate?
    
    enum UsernameLabelWidth: CGFloat {
        case compact    = 36.0
        case full       = 97.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        likeIcon.tintColor = UIColor(red: 14.0/255.0, green: 102.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        
        // Set placeholder for NameTextView
        if let textView = userDescriptionTextView {
            userDescriptionTextView.tintColor = UIColor(red: 14.0/255.0, green: 102.0/255.0, blue: 129.0/255.0, alpha: 1.0)
            let placeholderText = NSLocalizedString("profile_description_placeholder", comment: "")
            applyPlaceholderStyle(userDescriptionTextView, placeholderText: placeholderText)
            userDescriptionTextView.alpha = 0.0
        }
        
        if let topView = topTapableView {
            self.topTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UserHeaderView.topTapped(_:)))
            topView.isHidden = true
            topView.addGestureRecognizer(topTapGestureRecognizer!)
        }
    }
    
    func applyPlaceholderStyle(_ aTextview: UITextView, placeholderText: String)
    {
        // make it look (initially) like a placeholder
        aTextview.textColor = UIColor(white: 0.5, alpha: 1.0)
        aTextview.text = placeholderText
    }
    
    func applyNonPlaceholderStyle(_ aTextview: UITextView)
    {
        // make it look like normal text instead of a placeholder
        aTextview.textColor = UIColor.darkText
        aTextview.alpha = 1.0
    }
    
    // MARK: - Actions
    
    @IBAction func closeButtonPressed(_ sender: AnyObject) {
        if let del = delegate {
            del.closeButtonPressed(sender)
        }
    }
    
    @objc func topTapped(_ sender: UITapGestureRecognizer) {
        if let del = delegate {
            del.usernameLabelPressed()
        }
    }
    
    func update(_ user: User) {
        userImageView.sd_setImage(with: user.avatarURL())
        
        usernameLabel.text  = user.name
        likeCountLabel.text = "\(user.likes)"
        
        if let label = userDescriptionLabel {
            userDescriptionLabel.text   = user.desc
        } else {
            userDescriptionTextView.alpha = 1.0
            if let text = user.desc {
                if !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
                    applyNonPlaceholderStyle(userDescriptionTextView)
                    userDescriptionTextView.text = user.desc
                }
            }
        }
        
        if let live = liveLabel {
            live.isHidden = !user.isLive
        }
        
        calculateUsernameLabelWidth()
    }
    
    fileprivate func calculateUsernameLabelWidth() {
        usernameLabel.sizeToFit()
        
        var maxWidth: CGFloat = 0.0
        if let close = closeButton {
            let kPadding: CGFloat = 8.0
            maxWidth = self.frame.width - (kPadding * 4.0 + userImageView.bounds.width + close.frame.width)
        } else {
            maxWidth = self.frame.width - (20.0 + userImageView.bounds.width + 30.0)
        }
        
        if usernameLabel.frame.width > maxWidth {
            usernameLabel.frame = CGRect(x: usernameLabel.frame.origin.x, y: usernameLabel.frame.origin.y, width: maxWidth, height: usernameLabel.frame.height)
            usernameLabelWidth.constant = maxWidth
        } else {
            usernameLabelWidth.constant = usernameLabel.frame.width
        }
        self.layoutIfNeeded()
    }
    
    func updateAvatar(_ user: User, placeholder: UIImage) {
        // Change image in UIImageView
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.userImageView.alpha = 0.0
            }, completion: { (finished) -> Void in
                self.userImageView.image = placeholder
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.userImageView.alpha = 1.0
                })
        })
        
        // Clear cache
        SDImageCache.shared().removeImage(forKey: user.avatarURL().absoluteString, fromDisk: true)
        
        // Download and put in cache new image
        user.avatar = nil
        SDWebImagePrefetcher.shared().prefetchURLs([user.avatarURL()])
    }
        
    func showFullMode() {
        if isFullMode {
            return
        }
        isFullMode = true
        
        UIView.animate(withDuration: UserViewController.animationDuration, animations: { () -> Void in
            self.userImageView.alpha        = 1.0
            self.likeIcon.alpha             = 1.0
            self.likeCountLabel.alpha       = 1.0
            self.liveLabel.alpha            = 1.0
            self.userDescriptionLabel.alpha = 1.0
            
            self.usernameLabelLeft.constant = UsernameLabelWidth.full.rawValue
            self.height.constant            = UserHeaderViewHeight.full.rawValue
            
            self.superview!.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            if let topView = self.topTapableView {
                topView.isHidden = true
            }
        }) 
    }
    
    func showCompactMode() {
        if !isFullMode {
            return
        }
        isFullMode = false
        
        UIView.animate(withDuration: UserViewController.animationDuration, animations: { () -> Void in
            self.userImageView.alpha        = 0.0
            self.likeIcon.alpha             = 0.0
            self.likeCountLabel.alpha       = 0.0
            self.liveLabel.alpha            = 0.0
            self.userDescriptionLabel.alpha = 0.0
            
            self.usernameLabelLeft.constant = self.frame.width / 2.0 - self.usernameLabel.frame.width / 2.0
            self.height.constant            = UserHeaderViewHeight.compact.rawValue
            
            self.superview!.layoutIfNeeded()
        }, completion: { (finished) -> Void in
            if let topView = self.topTapableView {
                topView.isHidden = false
            }
        }) 
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let del = delegate {
            del.descriptionWillStartEdit()
        }
        
        if textView.textColor == UIColor(white: 0.5, alpha: 1.0)
        {
            // move cursor to start
            moveCursorToStart(textView)
        }
        
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var updatedText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        updatedText = updatedText.handleEmoji()
        
        if updatedText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty {
            let placeholderText = NSLocalizedString("profile_description_placeholder", comment: "")
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
        
        // Remove placeholder text if it is shown
        if userDescriptionTextView.textColor == UIColor(white: 0.5, alpha: 1.0) && !text.isEmpty {
            textView.text = ""
            applyNonPlaceholderStyle(textView)
            return true
        }
        
        return true
    }
    
    func moveCursorToStart(_ textView: UITextView)
    {
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
