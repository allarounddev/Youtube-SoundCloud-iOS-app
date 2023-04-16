//
//  TwitterTool.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterTool: SocialTool {
    func post(_ username: String, live: URL) {
        
        let format  = NSLocalizedString("create_stream_post_message", comment: "")
        let text    = NSString(format: format as NSString, username, live.absoluteString)
        let message: [AnyHashable: Any] = [ "status" : text ]
        
        let client = TWTRAPIClient()
        let url = "https://api.twitter.com/1.1/statuses/update.json";
        let preparedRequest = client.urlRequest(withMethod: "POST", urlString: url, parameters: message, error: nil)
        client.sendTwitterRequest(preparedRequest, completion: { (response, data, error) -> Void in
        })
        
    }
}
