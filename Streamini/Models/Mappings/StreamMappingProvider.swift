//
//  StreamMappingProvider.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class StreamMappingProvider: NSObject {
    
    class func cityResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: NSMutableDictionary.self)
        mapping?.addAttributeMappings(from: ["name"])
        
        return mapping!
    }
    
    class func streamRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.request()
        
        mapping?.addAttributeMappings(from: [
            "id"            : "id",
            "title"         : "title",
            "streamHash"    : "hash",
            "ended"         : "ended",
            "viewers"       : "viewers",
            "tviewers"      : "tviewers",
            "rviewers"      : "rviewers",
            "city"          : "city",
            "lon"           : "lon",
            "lat"           : "lat",
            "likes"         : "likes",
            "rlikes"        : "rlikes",
            "price"         : "price",
            "videotype"     : "videotype",
            "extras"        : "extras",
            "isplaylist"    : "isplaylist"
        ])
        
        let userMapping = UserMappingProvider.userRequestMapping()
        let userRelationshipMapping = RKRelationshipMapping(fromKeyPath: "user", toKeyPath: "user", with: userMapping)
        mapping?.addPropertyMapping(userRelationshipMapping)
        
        return mapping!
    }
        
    class func streamResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: Stream.self)
        
        mapping?.addAttributeMappings(from: [
            "id"            : "id",
            "title"         : "title",
            "hash"          : "streamHash",
            "ended"         : "ended",
            "viewers"       : "viewers",
            "tviewers"      : "tviewers",
            "rviewers"      : "rviewers",
            "city"          : "city",
            "lon"           : "lon",
            "lat"           : "lat",
            "likes"         : "likes",
            "rlikes"        : "rlikes",
            "price"         : "price",
            "videotype"     : "videotype",
            "extras"        : "extras",
            "isplaylist"    : "isplaylist"
        ])
        
        let userMapping = UserMappingProvider.userResponseMapping()
        let userRelationshipMapping = RKRelationshipMapping(fromKeyPath: "user", toKeyPath: "user", with: userMapping)
        mapping?.addPropertyMapping(userRelationshipMapping)
        
        return mapping!
    }
    
    class func viewersResponseMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: NSMutableDictionary.self)
        mapping?.addAttributeMappings(from: ["viewers", "likes"])
        
        let userMapping = UserMappingProvider.userResponseMapping()
        let userRelationshipMapping = RKRelationshipMapping(fromKeyPath: "users", toKeyPath: "users", with: userMapping)
        mapping?.addPropertyMapping(userRelationshipMapping)
        
        return mapping!
    }
        
    class func createStreamRequestMapping() -> RKObjectMapping {
        let mapping = RKObjectMapping.request()
        mapping?.addAttributeMappings(from: ["title", "lon", "lat", "city", "price", "videotype", "extras", "isplaylist"])
        return mapping!
    }    
}
