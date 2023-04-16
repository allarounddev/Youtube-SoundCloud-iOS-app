//
//  UserExtension.swift
//  Streamini
//
//  Created by Vasily Evreinov on 15/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

extension User {
    class func serialize(_ user: User) -> NSDictionary {
        var values: [AnyObject] = [user.id as AnyObject, user.name as AnyObject]
        var keys = ["id", "name"]
        
        if let avatar = user.avatar {
            values.append(avatar as AnyObject)
            keys.append("avatar")
        }
        
        let dictionary: NSDictionary = NSDictionary(objects: values, forKeys: keys as [NSCopying])
        return dictionary
    }
    
    class func deserialize(_ data: NSDictionary) -> User {
        let user    = User()
        user.id     = data["id"] as! UInt
        user.name   = (data["name"] as? String)!
        user.avatar = data["avatar"] as? String
        
        return user
    }
    
    override func validateValue(_ ioValue: AutoreleasingUnsafeMutablePointer<AnyObject?>, forKeyPath inKeyPath: String) throws {
        if let _: AnyObject = ioValue.pointee {
            if (inKeyPath == "avatar" || inKeyPath == "desc") && ioValue.pointee is NSNull {
                ioValue.pointee = nil
                return
            }
        }
        try super.validateValue(ioValue, forKeyPath: inKeyPath)
    }
    
    func avatarURL() -> URL {
        if let avatar = self.avatar {
            if !avatar.isEmpty {
                return URL(string: avatar)!
            }
        }
        
        let (accessKeyId, _, region, _, imagesBucket) = Config.shared.amazon()
        let site = Config.shared.site()
        let s3site = region == "us-east-1" ? "s3" : "s3-\(region)"
        let string = accessKeyId == ""
            ? "\(site)/uploads/\(self.id)-avatar.jpg"
            : "http://\(s3site).amazonaws.com/\(imagesBucket)/\(self.id)-avatar.jpg"
        
        return URL(string: string)!

    }
}
