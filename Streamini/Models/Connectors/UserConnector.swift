//
//  UserConnector.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class UserConnector: Connector {
    
    func logout(_ success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/logout"
        
        manager?.post(nil, path: path, parameters: nil, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                failure(error.toNSError())
            } else {
                success()
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func get(_ id: UInt?, success: @escaping (_ user: User) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user"
        
        let responseMapping = UserMappingProvider.userResponseMapping()
        
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let userResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        manager?.addResponseDescriptor(userResponseDescriptor)
        
        var params = self.sessionParams()
        if let uid = id {
            params!["id"] = uid
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.get(id, success: success, failure: failure)
                    }, failure: { () -> () in
                        failure(error.toNSError())
                    })
                } else {
                    failure(error.toNSError())
                }
            } else {
                let user = mappingResult?.dictionary()["data"] as! User
                success(user)
            }
        }) { (operation, error) -> Void in
            // failure code
            failure(error! as NSError)
        }
    }
    
    func friends(_ success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let data = NSDictionary(objects: [
            A0SimpleKeychain().string(forKey: "id")!,
            A0SimpleKeychain().string(forKey: "token")!,
            A0SimpleKeychain().string(forKey: "secret")!,
            A0SimpleKeychain().string(forKey: "type")!], forKeys: [
                "id" as NSCopying,
                "token" as NSCopying,
                "secret" as NSCopying,
                "type" as NSCopying])
        usersList("social/friends", data: data, success: success, failure: failure)
    }
    
    func followers(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        usersList("user/followers", data: data, success: success, failure: failure)
    }
    
    func following(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        usersList("user/following", data: data, success: success, failure: failure)
    }
    
    func blocked(_ data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        usersList("user/blocked", data: data, success: success, failure: failure)
    }
    
    func avatar(_ success: @escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/avatar"
        
        manager?.post(nil, path: path, parameters: self.sessionParams(), success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status{
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.avatar(success, failure: failure)
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
            failure(error! as NSError)
        }
    }
    
    func uploadAvatar(_ filename: String, data: Data, success: @escaping () -> (), failure: @escaping (_ error: NSError) -> (), progress: @escaping ((UInt, Int64, Int64) -> Void)) {
        let path = "user/avatar"
        
        let request =
            manager?.multipartFormRequest(with: nil, method: RKRequestMethod.POST, path: path, parameters: self.sessionParams()) { (formData) -> Void in
                formData?.appendPart(withFileData: data, name: "image", fileName: filename, mimeType: "image/jpeg")
        }
        
        let operation = manager?.objectRequestOperation(with: request as URLRequest?, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status{
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.uploadAvatar(filename, data: data, success: success, failure: failure, progress: progress)
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
            failure(error! as NSError)
        }
        
        operation?.httpRequestOperation.setUploadProgressBlock(progress)
        manager?.enqueue(operation)
    }
    
    func userDescription(_ text: String, success:@escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/description"
        
        var params = self.sessionParams()
        params!["text"] = text
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.userDescription(text, success: success, failure: failure)
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
            failure(error! as NSError)
        }
    }
    
    func userPaypal(_ text: String, success:@escaping () -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/paypal"
        
        var params = self.sessionParams()
        params!["paypal"] = text
        
        manager?.post(nil, path: path, parameters: params, success: { (operation, mappingResult) -> Void in
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.userPaypal(text, success: success, failure: failure)
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
            failure(error! as NSError)
        }
    }
    
    fileprivate func usersList(_ path: String, data: NSDictionary, success: @escaping (_ users: [User]) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let responseMapping = UserMappingProvider.userResponseMapping()
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let userResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.GET, pathPattern: nil, keyPath: "data.users", statusCodes: statusCode)
        manager?.addResponseDescriptor(userResponseDescriptor)
        
        var params = self.sessionParams()
        if let id = data["id"] {
            params!["id"] = id
        }
        if let page = data["p"] {
            params!["p"] = page
        }
        if let query = data["q"] {
            params!["q"] = query
        }
        if let type = data["type"] {
            params!["type"] = type
        }
        if let token = data["token"] {
            params!["token"] = token
        }
        if let secret = data["secret"] {
            params!["secret"] = secret
        }
        
        manager?.getObjectsAtPath(path, parameters: params, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if error.status {
                if error.code == kLoginExpiredCode {
                    self.relogin({ () -> () in
                        self.usersList(path, data: data, success: success, failure: failure)
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
            // failure code
            failure(error! as NSError)
        }
    }
}
