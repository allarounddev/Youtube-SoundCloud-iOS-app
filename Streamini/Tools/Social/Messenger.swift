//
//  Messenger.swift
//  Streamini
//
//  Created by Vasily Evreinov on 07/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

protocol Messenger {
    func connect(_ streamId: UInt)
    func disconnect(_ streamId: UInt)
    func send(_ message: Message, streamId: UInt)
    func receive(_ handler: @escaping (_ message: Message)->())
}

class MessengerFactory: NSObject {
    class func getMessenger(_ name: String) -> Messenger? {
        if name == "pubnub" {
            return PubNubMessenger()
        }
        return nil
    }
}
