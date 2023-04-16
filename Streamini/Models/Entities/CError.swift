//
//  CError.swift
//  Streamini
//
//  Created by Vasily Evreinov on 08/02/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

let kLoginExpiredCode: UInt = 100
let kUnsuccessfullPing: UInt = 202
let kUserBlocked: UInt = 201
let kPaidStream: UInt = 1000
let kMoreCredits: UInt = 1001

@objc(CError)
class CError: NSObject{
    
//    static let kLoginExpiredCode: UInt = 100
//    static let kUnsuccessfullPing: UInt = 202
//    static let kUserBlocked: UInt = 201
//    static let kPaidStream: UInt = 1000
//    static let kMoreCredits: UInt = 1001
    
    @objc dynamic var status: Bool = false
    @objc dynamic var code: UInt = 0
    @objc dynamic var message: NSString = ""
    
    convenience override init() {
        self.init(status: false, code: 0, message: "")
    }
    
    init(status astatus:Bool, code acode:UInt, message amessage:NSString) {
        self.status = astatus
        self.code = acode
        self.message = amessage
        super.init()
    }

    func toNSError() -> NSError {
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = self.message
        userInfo["code"] = self.code
        
        let error = NSError(domain: "com.uniprogy.streamini", code: 1, userInfo: userInfo as? [String : Any])
        return error
    }
}


