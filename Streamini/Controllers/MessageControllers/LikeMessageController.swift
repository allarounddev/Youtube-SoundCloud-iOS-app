//
//  LikeMessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class LikeMessageController: NSObject, MessageControllerProtocol {
    var animator: Animator
    var likeView: UIView
    
    init (animator: Animator, likeView: UIView) {
        self.animator = animator
        self.likeView = likeView
        super.init()
    }
    
    func handle(_ message: Message) {
        animator.like(likeView)
    }
}
