//
//  Stream.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

@objc(Stream)
class Stream: NSObject {
    
    @objc dynamic var id: UInt = 0
    @objc dynamic var title:String = ""
    @objc dynamic var streamHash:String = ""
    @objc dynamic var lon: Double = 0
    @objc dynamic var lat: Double = 0
    @objc dynamic var city:String = ""
    @objc dynamic var ended: Date? = nil
    @objc dynamic var viewers: UInt = 0
    @objc dynamic var tviewers: UInt = 0
    @objc dynamic var rviewers: UInt = 0
    @objc dynamic var likes: UInt = 0
    @objc dynamic var rlikes: UInt = 0
    @objc dynamic var price: Double = 0
    @objc dynamic var videotype:String = ""
    @objc dynamic var extras:String = ""
    @objc dynamic var isplaylist = false
    @objc dynamic var user = User()
    
    convenience override init() {
        self.init(id: 0, title: "", streamHash: "", lon: 0, lat: 0, city: "", ended: Date(), viewers: 0, tviewers: 0, rviewers: 0, likes: 0, rlikes: 0, price: 0, videotype: "", extras: "", isplaylist: false, user: User())
    }
    
    init(id: UInt, title: String, streamHash: String, lon: Double, lat: Double, city: String, ended: Date, viewers: UInt, tviewers: UInt, rviewers: UInt, likes: UInt, rlikes: UInt, price: Double, videotype: String, extras: String, isplaylist: Bool, user: User) {
        
        self.id   = id
        self.title   = title
        self.streamHash = streamHash
        self.lon   = lon
        self.lat   = lat
        self.city = city
        self.ended   = ended
        self.viewers   = viewers
        self.tviewers = tviewers
        self.rviewers   = rviewers
        self.likes   = likes
        self.rlikes = rlikes
        self.price   = price
        self.videotype = videotype
        self.extras   = extras
        self.isplaylist   = isplaylist
        self.user = user
        
        super.init()
        
    }

    
}
