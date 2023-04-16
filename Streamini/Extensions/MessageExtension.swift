//
//  MessageExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 15/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

extension Message {
    
    // MARK: - Factory methods
    
    class func create(_ text: String) -> Message {
        let user = UserContainer.shared.logged()
        return Message(type: MessageType.Comment, text: text, from: user)
    }
    
    class func connected() -> Message {
        let user = UserContainer.shared.logged()
        return Message(type: MessageType.Connected, text: "", from: user)
    }
    
    class func disconnected() -> Message {
        let user = UserContainer.shared.logged()
        return Message(type: MessageType.Disconnected, text: "", from: user)
    }
    
    class func like() -> Message {
        let user = UserContainer.shared.logged()
        return Message(type: MessageType.Like, text: "", from: user)
    }
    
    class func closed() -> Message {
        let user = UserContainer.shared.logged()
        return Message(type: MessageType.Closed, text: "", from: user)
    }
    
    class func blocked(_ userId: UInt) -> Message {
        let user = UserContainer.shared.logged()
        return Message(type: MessageType.Blocked, text: "\(userId)", from: user)
    }
    
    // MARK: - Serialization
    
    class func serialize(_ message: Message) -> NSDictionary {
        let sender = User.serialize(message.sender)
        return NSDictionary(objects: [message.type.rawValue, message.text, sender], forKeys: ["type" as NSCopying, "text" as NSCopying, "sender" as NSCopying])
    }
    
    class func deserialize(_ dictionary: NSDictionary) -> Message {
        let type: MessageType = MessageType(rawValue: (dictionary["type"] as! String))!
        let text: String = dictionary["text"] as! String
        let userData = dictionary["sender"] as! NSDictionary
        let sender = User.deserialize(userData)
        
        return Message(type: type, text: text, from: sender)
    }
}
