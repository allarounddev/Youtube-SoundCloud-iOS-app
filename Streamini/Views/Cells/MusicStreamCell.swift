//
//  MusicStreamCell.swift
//  Streamini
//

import UIKit

class MusicStreamCell: StreamCell {
    @IBOutlet weak var streamNameLabel: UILabel!
    @IBOutlet weak var streamImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var repostBtn: UIButton!
    
//    var onButtonTapped: (() -> Void)? = nil

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
        
        streamNameLabel.text  = stream.title
        streamImageView.sd_setImage(with: stream.urlToStreamImage())
        userImageView.sd_setImage(with: stream.user.avatarURL())
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2
        userImageView.clipsToBounds = true
        streamImageView.layer.cornerRadius = streamImageView.frame.size.width / 2
        streamImageView.clipsToBounds = true
        
    }
    
    func updateMyStream(_ stream: Stream) {
        super.update(stream)
        streamNameLabel.text  = stream.title
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
