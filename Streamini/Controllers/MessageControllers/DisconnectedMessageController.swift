//
//  DisconnectedMessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class DisconnectedMessageController: NSObject, MessageControllerProtocol {
    var updateCounterFunction: (() -> ())?
    
    init (updateCounterFunction: (() -> ())?) {
        self.updateCounterFunction = updateCounterFunction
        super.init()
    }
    
    func handle(_ message: Message) {
        // update count viewers
        if let update = updateCounterFunction {
            update()
        }
    }
}
