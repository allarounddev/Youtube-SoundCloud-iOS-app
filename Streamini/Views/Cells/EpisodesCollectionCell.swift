//
//  EpisodesCollectionCell.swift
//  Streamini
//
//  Created by developer on 12/1/18.
//  Copyright © 2018 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit

class EpisodesCollectionCell: PZSwipedCollectionViewCell {
    
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamEndedLabel: UILabel!
    @IBOutlet weak var playImageView: UIImageView!
    
    
    var stream: Stream?
    weak var userSelectedDelegate: UserSelecting?
    var streamSelectedDelegate: StreamSelecting?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func update(_ stream: Stream) {
        self.stream = stream
        
        userLabel.text = stream.user.name
        streamNameLabel.text  = stream.title
        streamEndedLabel.text = stream.ended!.timeAgoSimple
        self.layer.borderWidth = 0.25
        self.layer.borderColor = UIColor.lightGray.cgColor

        
    }
    
    func updateMyStream(_ stream: Stream) {
        self.update(stream)
        userLabel.text = UserContainer.shared.logged().name

        streamNameLabel.text  = stream.title
        if let time = stream.ended {
            streamEndedLabel.text = time.timeAgoSimple
        } else {
            streamEndedLabel.text = ""
        }
        
        self.layoutIfNeeded()
    }
    
//    func calculateHeight() -> CGFloat {
//        streamNameLabel.sizeToFit()
//        return streamNameLabel.frame.size.height
//    }


    
    
}
