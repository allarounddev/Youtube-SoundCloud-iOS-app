//
//  Message.swift
//  Streamini
//
//  Created by Vasily Evreinov on 15/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

enum MessageType: String {
    case Comment        = "comment"
    case Connected      = "connected"
    case Disconnected   = "disconnected"
    case Like           = "like"
    case Closed         = "closed"
    case Blocked        = "blocked"
}

@objc(Message)
class Message: NSObject {
    var sender  = User()
    var type    = MessageType.Comment
    var text    = ""
    
    init(type: MessageType, text: String, from: User) {
        self.type   = type
        self.text   = text
        self.sender = from
        super.init()

    }
}
