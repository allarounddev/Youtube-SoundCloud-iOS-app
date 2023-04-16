//
//  RecentStreamCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class RecentStreamCell: StreamCell {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamEndedLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var playWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var repostBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func update(_ stream: Stream) {
        super.update(stream)
        
        userLabel.text = stream.user.name
        streamNameLabel.text  = stream.title
        streamEndedLabel.text = stream.ended!.timeAgoSimple
        streamImageView.sd_setImage(with: stream.urlToStreamImage())
        userImageView.sd_setImage(with: stream.user.avatarURL())
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
//        streamImageView.layer.cornerRadius = 30
        streamImageView.clipsToBounds = true


    }
    
    func updateMyStream(_ stream: Stream) {
        super.update(stream)
        
        userLabel.text = UserContainer.shared.logged().name
        
        var isLessThan24Hours = false
        if let date = stream.ended {
            isLessThan24Hours = Date().lessThan24Hours(date)
        }
        
        playImageView.isHidden  = !isLessThan24Hours
        self.isUserInteractionEnabled = isLessThan24Hours
        streamNameLabel.text  = stream.title
        
        if let time = stream.ended {
            streamEndedLabel.text = time.timeAgoSimple
        } else {
            streamEndedLabel.text = ""
        }

        
        playWidthConstraint.constant = (isLessThan24Hours) ? 24.0 : 0.0
        self.layoutIfNeeded()
    }
    
    func calculateHeight() -> CGFloat {
        streamNameLabel.sizeToFit()
        return streamNameLabel.frame.size.height
    }
    
    @IBAction func repostBtnClicked(_ sender: Any) {
        
        if let onButtonTapped = self.onButtonTapped {
            onButtonTapped()
        }
        
    }

}
