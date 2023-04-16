//
//  FollowerCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class FollowerCell: UITableViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    weak var userSelectedDelegate: UserSelecting?
    var userSelectingHandler: UserSelectingHandler?
    
    func update(_ user: User) {
        if let delegate = userSelectedDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: delegate, user: user)
        }
        
        userImageView.sd_setImage(with: user.avatarURL())
        
        usernameLabel.text = user.name
    }
}
