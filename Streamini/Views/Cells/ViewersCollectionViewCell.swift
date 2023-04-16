//
//  ViewersCollectionViewCell.swift
//  Streamini
//
//  Created by Vasily Evreinov on 21/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class ViewersCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var userImageView: UIImageView!
    weak var userSelectedDelegate: UserSelecting?
    var user: User?
    var userSelectingHandler: UserSelectingHandler?
    
    func update(_ user: User) {
        self.user = user
        
        userImageView.sd_setImage(with: user.avatarURL())
        
        if let delegate = userSelectedDelegate {
            self.userSelectingHandler = UserSelectingHandler(imageView: userImageView, delegate: delegate, user: user)
        }
    }
}
