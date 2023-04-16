//
//  SocialConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 22/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class SocialConnector: Connector {
    
    func users(_ data: NSDictionary, success: @escaping (_ top: [User], _ featured: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "social"
        
        var params = self.sessionParams()
        if let page = data["p"] {
            params!["p"] = page
        }
        
        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let topResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.top", statusCodes: statusCode)
        manager?.addResponseDescriptor(topResponseDescriptor)
        
        let featuresResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.featured", statusCodes: statusCode)
        manager?.addResponseDescriptor(featuresResponseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.users(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let top         = mappingResult?.dictionary()["data.top"] as! [User]
                let featured    = mappingResult?.dictionary()["data.featured"] as! [User]
                success(_: top, featured)
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func search(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "social/search"
        
        var params = self.sessionParams()
        if let page = data["p"] {
            params!["p"] = page
        }
        
        if let query = data["q"] {
            params!["q"] = query
        }

        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let responseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.users", statusCodes: statusCode)
        manager?.addResponseDescriptor(responseDescriptor)
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.search(data, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let users = mappingResult?.dictionary()["data.users"] as! [User]
                success(users)
            }
        }) { (operation, error) -> Void in
            failure(error! as NSError)
        }
    }
    
    func follow(_ userId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "social/follow"
        
        var params = self.sessionParams()
        params!["id"] = userId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.follow(userId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func unfollow(_ userId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "social/unfollow"
        
        var params = self.sessionParams()
        params!["id"] = userId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.unfollow(userId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func block(_ userId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "social/block"
        
        var params = self.sessionParams()
        params!["id"] = userId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.block(userId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func unblock(_ userId: UInt, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "social/unblock"
        
        var params = self.sessionParams()
        params!["id"] = userId
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.unblock(userId, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
}
