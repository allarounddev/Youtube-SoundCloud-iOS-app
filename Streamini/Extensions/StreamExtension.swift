//
//  StreamExtension.swift
//  Streamini
//
//  Created by Evghenii Todorov on 10/29/15.
//  Copyright © 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

extension Stream {
    
    func urlToStreamImage() -> URL {
        let (accessKeyId, _, region, _, imagesBucket) = Config.shared.amazon()
        let site = Config.shared.site()
        let s3site = region == "us-east-1" ? "s3" : "s3-\(region)"
        let string = accessKeyId == ""
            ? "\(site)/uploads/\(self.user.id)-\(self.id)-screenshot.jpg"
            : "http://\(s3site).amazonaws.com/\(imagesBucket)/\(self.user.id)-\(self.id)-screenshot.jpg"
        return URL(string: string)!
    }
    
}
