//
//  Connector.swift
//  Test
//
//  Created by Vasily Evreinov on 1/27/15.
//  Copyright (c) 2015 Direct Invent. All rights reserved.
//

import UIKit

class Connector: NSObject {
    var manager = RKObjectManager(baseURL: Connector.baseUrl())
    var errorDescriptor:RKResponseDescriptor?
    
    class func baseUrl() -> URL {
        let (host) = Config.shared.api()
        return URL(string: host)!
    }
    
    override init () {
        super.init()
        self.manager?.requestSerializationMIMEType = RKMIMETypeFormURLEncoded
        self.addErrorResponseDescriptor()
    }
    
    func sessionParams() -> [AnyHashable: Any]? {
        if let session = A0SimpleKeychain().string(forKey: "PHPSESSID") {
            let params: [AnyHashable: Any] = [ "PHPSESSID" : session ]
            return params
        } else {
            return nil
        }
    }
    
    func loginData() -> NSDictionary? {
        let data = NSMutableDictionary()
        if A0SimpleKeychain().string(forKey: "id") != nil {
            data["id"] = A0SimpleKeychain().string(forKey: "id")
        }
        if A0SimpleKeychain().string(forKey: "token") != nil {
            data["token"] = A0SimpleKeychain().string(forKey: "token")
        }
        if A0SimpleKeychain().string(forKey: "secret") != nil {
            data["secret"] = A0SimpleKeychain().string(forKey: "secret")
        }
        if A0SimpleKeychain().string(forKey: "type") != nil {
            data["type"] = A0SimpleKeychain().string(forKey: "type")
        }
        
        return (data.count == 4) ? data : nil
    }
    
    func login(_ loginData: NSDictionary, success: @escaping (_ session: String) -> (), failure: @escaping (_ error: NSError) -> ()) {
        let path = "user/login"
        
        let requestMapping  = UserMappingProvider.loginRequestMapping()
        let responseMapping = UserMappingProvider.loginResponseMapping()
        
        let requestDescriptor = RKRequestDescriptor(mapping: requestMapping, objectClass: NSDictionary.self, rootKeyPath: nil, method: RKRequestMethod.POST)
        
        manager?.addRequestDescriptor(requestDescriptor)
        
        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        
        let loginResponseDescriptor = RKResponseDescriptor(mapping: responseMapping, method: RKRequestMethod.POST, pathPattern: nil, keyPath: "data", statusCodes: statusCode)
        manager?.addResponseDescriptor(loginResponseDescriptor)
        
        manager?.post(loginData, path: path, parameters: nil, success: { (operation, mappingResult) -> Void in
            // success code
            let error:CError = self.findErrorObject(mappingResult: mappingResult!)!
            if !error.status {
                failure(error.toNSError())
            } else {
                let data = mappingResult?.dictionary()["data"] as! NSDictionary
                let session = data["session"] as! String
                success(session)
            }
            }) { (operation, error) -> Void in
                // failure code
                failure(error! as NSError)
        }
    }
    
    func relogin(_ success: @escaping () -> (), failure: @escaping () -> ()) {
        func loginSuccess(_ session: String) {
            success()
        }
        func loginFailure(_ error: NSError) {
            failure()
        }
        
        if let data = loginData() {
            self.login(data, success: loginSuccess, failure: loginFailure)
        } else {
            failure()
        }
    }

    func addErrorResponseDescriptor() {
        let mapping = ErrorMappingProvider.errorObjectMapping()

        let statusCode = RKStatusCodeIndexSetForClass(RKStatusCodeClass.successful)
        self.errorDescriptor = RKResponseDescriptor(mapping: mapping, method:RKRequestMethod.any, pathPattern: nil, keyPath: "", statusCodes: statusCode)
        self.manager?.addResponseDescriptor(self.errorDescriptor)
    }
    
    func findErrorObject(mappingResult: RKMappingResult) -> CError? {
        for obj in mappingResult.array() {
            if obj is CError {
                return obj as? CError
            }
        }
        
        return nil
    }
}
