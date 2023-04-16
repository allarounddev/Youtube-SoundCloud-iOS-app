//
//  PlayListCollectionCell.swift
//  Streamini
//
//  Created by developer on 8/15/18.
//  Copyright © 2018 UniProgy s.r.o. All rights reserved.
//

import Foundation
import UIKit

class PlayListCollectionCell: PZSwipedCollectionViewCell {
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var streamNameLabel: UILabel!
    
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
        streamImageView.sd_setImage(with: stream.urlToStreamImage())

    }

    func updateMyStream(_ stream: Stream) {
        self.update(stream)
        streamNameLabel.text  = stream.title
        self.layoutIfNeeded()
    }

//    func calculateHeight() -> CGFloat {
//        streamNameLabel.sizeToFit()
//        return streamNameLabel.frame.size.height
//    }

    
}
