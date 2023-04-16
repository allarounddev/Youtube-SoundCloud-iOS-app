//
//  ReplayView.swift
// Streamini
//
//  Created by Vasily Evreinov on 24/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol ReplayViewDelegate: class {
    func replayViewWillBeShown(_ replayView: ReplayView)
    func replayViewWillBeHidden(_ replayView: ReplayView)
    func replayViewStreamDidEnd(_ replayView: ReplayView)
    func replayViewPlayButtonPressed(_ replayView: ReplayView)
    func replayViewCloseButtonPressed(_ replayView: ReplayView)
    func replayViewViewersButtonPressed(_ replayView: ReplayView)
    func replayViewReplaysButtonPressed(_ replayView: ReplayView)
}

class ReplayView: UIView {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamNameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesValueLabel: UILabel!
    @IBOutlet weak var viewersLabel: UILabel!
    @IBOutlet weak var viewersValueLabel: UILabel!
    @IBOutlet weak var replaysLabel: UILabel!
    @IBOutlet weak var replaysValueLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var viewersButton: UIButton!
    @IBOutlet weak var replaysButton: UIButton!
    
    var viewersIsShown = false
    var replaysIsShown = false
    weak var delegate: ReplayViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = true
        
        self.backgroundColor = UIColor(white: 0.0, alpha: 0.6)
        
        playButton.addTarget(self, action: #selector(ReplayView.playButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        closeButton.addTarget(self, action: #selector(ReplayView.closeButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        viewersButton.addTarget(self, action: #selector(ReplayView.viewersButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        replaysButton.addTarget(self, action: #selector(ReplayView.replaysButtonPressed(_:)), for: UIControl.Event.touchUpInside)
        
        viewersLabel.text   = NSLocalizedString("stat_viewers", comment: "")
        likesLabel.text     = NSLocalizedString("stat_likes", comment: "")
        replaysLabel.text   = NSLocalizedString("stat_replays", comment: "")
    }
    
    @objc func playButtonPressed(_ sender: UIView) {
        if let del = delegate {
            playButton.isHidden = true
            del.replayViewPlayButtonPressed(self)
        }
    }
    
    @objc func closeButtonPressed(_ sender: UIView) {
        if let del = delegate {
            del.replayViewCloseButtonPressed(self)
        }
    }
    
    @objc func viewersButtonPressed(_ sender: UIView) {
        if let del = delegate {
            del.replayViewViewersButtonPressed(self)
        }
        viewersIsShown = !viewersIsShown
        replaysIsShown = false
        
        viewersButton.superview?.alpha = viewersIsShown ? 1.0 : 0.5
        replaysButton.superview?.alpha = 0.5
    }
    
    @objc func replaysButtonPressed(_ sender: UIView) {
        if let del = delegate {
            del.replayViewReplaysButtonPressed(self)
        }
        replaysIsShown = !replaysIsShown
        viewersIsShown = false
        replaysButton.superview?.alpha = replaysIsShown ? 1.0 : 0.5
        viewersButton.superview?.alpha = 0.5
    }
    
    func show() {
        self.isUserInteractionEnabled = true
        self.playButton.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.replayViewWillBeShown(self)
        }
    }
    
    func streamEnd() {
        self.isUserInteractionEnabled = true
        self.playButton.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.alpha = 1.0
        })
        
        if let del = delegate {
            del.replayViewStreamDidEnd(self)
        }
    }
    
    func hide(_ animated: Bool) {
        self.isUserInteractionEnabled = false
        
        if animated {
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.alpha = 0.0
            })
        } else {
            self.alpha = 0.0
        }
        
        if let del = delegate {
            del.replayViewWillBeHidden(self)
        }
    }
    
    func update(_ stream: Stream) {
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
        
        likesValueLabel.text = "\(stream.likes)"
        viewersValueLabel.text = "\(stream.tviewers)"
        replaysValueLabel.text = "\(stream.rviewers)"
        
        self.layoutIfNeeded()
    }
}
