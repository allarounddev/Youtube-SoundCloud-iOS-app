//
//  BlockedMessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 03/09/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class BlockedMessageController: NSObject, MessageControllerProtocol {
    let blockStreamFunction: (_ userId: UInt) -> ()
    
    init (blockStreamFunction: @escaping (_ userId: UInt) -> ()) {
        self.blockStreamFunction = blockStreamFunction
        super.init()
    }
    
    func handle(_ message: Message) {
        let userId = UInt(Int(message.text)!)
        blockStreamFunction(userId)
    }
}
