//
//  MessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol MessageControllerProtocol {
    func handle(_ message: Message)
}

class MessageController: NSObject {
    
    class func getMessageControllerForJoin(_ type: MessageType, viewController: JoinStreamViewController) -> MessageControllerProtocol? {
        
        if type == MessageType.Connected {
            return ConnectMessageController(updateCounterFunction: viewController.updateCounter)
        }
        if type == MessageType.Disconnected {
            return DisconnectedMessageController(updateCounterFunction: viewController.updateCounter)
        }
        if type == MessageType.Comment {
            return CommentMessageController(commentsTableView: viewController.commentsTableView, commentsDataSource: viewController.commentsDataSource)
        }
        if type == MessageType.Like {
            return LikeMessageController(animator: viewController.animator, likeView: viewController.likeView)
        }
        if type == MessageType.Closed {
            return ClosedMessageController(closeStreamFunction: viewController.closeStream)
        }
        if type == MessageType.Blocked {
            return BlockedMessageController(blockStreamFunction: viewController.blockStream)
        }
        return nil
    }
    
    class func getMessageControllerForOwner(_ type: MessageType, viewController: LiveStreamViewController) -> MessageControllerProtocol? {
        
        if type == MessageType.Connected {
            return ConnectMessageController(updateCounterFunction: viewController.updateCounter)
        }
        if type == MessageType.Disconnected {
            return DisconnectedMessageController(updateCounterFunction: viewController.updateCounter)
        }
        if type == MessageType.Comment {
            return CommentMessageController(commentsTableView: viewController.commentsTableView, commentsDataSource: viewController.commentsDataSource)
        }
        if type == MessageType.Like {
            return LikeMessageController(animator: viewController.animator, likeView: viewController.likeView)
        }
        return nil
    }
}
