//
//  SocialTool.swift
//  Streamini
//
//  Created by Vasily Evreinov on 23/06/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol SocialTool {
    func post(_ username: String, live: URL)
}

class SocialToolFactory {
    class func getSocial(_ name: String) -> SocialTool? {
        if name == "Twitter" {
            return TwitterTool()
        }
        return nil
    }
}
