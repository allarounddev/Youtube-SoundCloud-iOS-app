//
//  InfoView.swift
//  Streamini
//
//  Created by Vasily Evreinov on 21/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol InfoViewDelegate: class {
    func infoViewWillBeShown(_ infoView: InfoView)
    func infoViewWillBeHidden(_ infoView: InfoView)
    func reportButtonPressed()
    func shareButtonPressed()
}

class InfoView: UIView {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    var stream: Stream?
    weak var delegate: InfoViewDelegate?
    weak var userSelectingDelegate: UserSelecting?
    var userSelectingHandler: UserSelectingHandler?
    
    // MAKR: - View life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        
        shareButton.addTarget(self, action: #selector(InfoView.shareButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        reportButton.addTarget(self, action: #selector(InfoView.reportButtonPressed(_:)), for: UIControl.Event.touchUpInside)
    }
    
    // MARK: - Actions
    
    @IBAction func tapGesturePerformed(_ sender: AnyObject) {
        self.hide()
    }
    
    @objc func shareButtonPressed(_ sender: UIButton) {
        if let del = self.delegate {
            del.shareButtonPressed()
        }
    }
    
    @objc func reportButtonPressed(_ sender: UIButton) {
        if let del = self.delegate {
            del.reportButtonPressed()
        }
    }
    
    // MARK: - Show/hide methods
    
    func show(_ isOwner: Bool) {
        shareButton.isHidden  = isOwner
        reportButton.isHidden = isOwner
        self.isUserInteractionEnabled = true
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.infoViewWillBeShown(self)
        }
    }
    
    func hide() {
        self.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.alpha = 0.0
        })
        
        if let del = delegate {
            del.infoViewWillBeHidden(self)
        }
    }
    
    // MARK: - Update data
    
    func update(_ stream: Stream) {
        func setupButton(_ button: UIButton, image: UIImage, title: String, top: CGFloat) {
            button.setImage(image, for: UIControl.State())
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15.0, bottom: 0.0, right: 0.0)
            button.imageEdgeInsets = UIEdgeInsets(top: top, left: 0.0, bottom: 0.0, right: 0.0)
            button.setTitle(title, for: UIControl.State())
            button.setImageTintColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State())
            button.setImageTintColor(UIColor(white: 1.0, alpha: 0.5), for: UIControl.State.highlighted)
            button.setTitleColor(UIColor(white: 1.0, alpha: 1.0), for: UIControl.State())
            button.setTitleColor(UIColor(white: 1.0, alpha: 0.5), for: UIControl.State.highlighted)
        }
        
        self.stream = stream
        
        if let del = userSelectingDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: del, user: stream.user)
        }
        
        streamNameLabel.text = stream.title
        let expectedSize = streamNameLabel.sizeThatFits(CGSize(width: streamNameLabel.bounds.size.width, height: 10000))
        streamNameHeightConstraint.constant = expectedSize.height
        
        if !stream.city.isEmpty {
            locationLabel.text = stream.city
            
            let size = locationLabel.sizeThatFits(locationLabel.bounds.size)
            locationWidthConstraint.constant = size.width + 10
            locationLabel.isHidden = false
        }
        
        usernameLabel.text = stream.user.name
        
        userImageView.sd_setImage(with: stream.user.avatarURL())

        let shareText = NSLocalizedString("stream_info_share_button", comment: "")
        setupButton(shareButton, image: UIImage(named: "share")!, title: shareText, top: -5.0)
        
        let reportText = NSLocalizedString("stream_info_report_button", comment: "")
        setupButton(reportButton, image: UIImage(named: "report")!, title: reportText, top: 0.0)
        
        self.layoutIfNeeded()
    }
}
