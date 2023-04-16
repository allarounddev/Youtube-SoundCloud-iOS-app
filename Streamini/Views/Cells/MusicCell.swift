//
//  MusicCell.swift
//  Streamini
//

import UIKit

class MusicCell: UITableViewCell {
    @IBOutlet private weak var labelTitle: UILabel?
    @IBOutlet private weak var labelArtist: UILabel?
    @IBOutlet weak var avatarImageView: UIImageView!
    var imageCache = NSCache<AnyObject, AnyObject>()
    
    var track: Track? {
        didSet {
            labelTitle?.text = track?.title
            labelArtist?.text = track?.createdBy.username
            avatarImageView.sd_setImage(with: self.track?.artworkImageURL.highURL)
        }
    }
}
