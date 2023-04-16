//
//  PeopleCellTableViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 10/08/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class PeopleCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesIcon: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var userStatusButton: SensibleButton!
    weak var delegate: LinkedUserCellDelegate?
    var user: User?
    
    var isStatusOn = false {
        didSet {
            let image: UIImage?
            if isStatusOn {
                image = UIImage(named: "checkmark")
            } else {
                image = UIImage(named: "plus")
            }
            userStatusButton.setImage(image!, for: UIControl.State())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(_ user: User) {
        self.user = user
        
        userImageView.sd_setImage(with: user.avatarURL())
        
        usernameLabel.text      = user.name
        likesLabel.text         = "\(user.likes)"
        descriptionLabel.text   = user.desc
        
        userStatusButton.isHidden = (UserContainer.shared.logged().id == user.id)
        isStatusOn = user.isFollowed
        userStatusButton.addTarget(self, action: #selector(PeopleCell.statusButtonPressed(_:)), for: UIControl.Event.touchUpInside)
    }
    
    @objc func statusButtonPressed(_ sender: AnyObject) {
        if let del = delegate {
            del.willStatusChanged(self)
        }
    }

}
