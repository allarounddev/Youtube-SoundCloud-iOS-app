//
//  User.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

@objc(User)
class User: NSObject {
    
    @objc dynamic var id: UInt
    @objc dynamic var name:String
    @objc dynamic var sname:String
    @objc dynamic var avatar: String?
    @objc dynamic var likes: UInt
    @objc dynamic var recent: UInt
    @objc dynamic var followers: UInt
    @objc dynamic var following: UInt
    @objc dynamic var streams: UInt
    @objc dynamic var blocked: UInt
    @objc dynamic var desc: String?
    @objc dynamic var isLive: Bool
    @objc dynamic var isFollowed:Bool
    @objc dynamic var isBlocked:Bool
    @objc dynamic var paypal:String
    @objc dynamic var earned: UInt
    
    convenience override init() {
        self.init(id: 0, name: "", sname: "", avatar: "", likes: 0, recent: 0, followers: 0, following: 0, streams: 0, blocked: 0, desc: "", isLive: false, isFollowed: false, isBlocked: false, paypal: "", earned: 0)
    }
    
    init(id: UInt, name: String, sname: String, avatar: String, likes: UInt, recent: UInt, followers: UInt, following: UInt, streams: UInt, blocked: UInt, desc: String, isLive: Bool, isFollowed: Bool, isBlocked: Bool, paypal: String, earned: UInt) {

        self.id   = id
        self.name   = name
        self.sname = sname
        self.avatar   = avatar
        self.likes   = likes
        self.recent = recent
        self.followers   = followers
        self.following   = following
        self.streams = streams
        self.blocked   = blocked
        self.desc   = desc
        self.isLive = isLive
        self.isFollowed   = isFollowed
        self.isBlocked = isBlocked
        self.paypal   = paypal
        self.earned   = earned
        super.init()

    }

}
