//
//  UserContainer.swift
//  Smart Out
//
//  Created by Vasily Evreinov on 08/02/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import Foundation

class UserContainer {
    // loged in user
    fileprivate var loggedUser: User?
    var image: UIImage?
    
    class var shared : UserContainer {
        struct Static {
            static let instance : UserContainer = UserContainer()
        }
        return Static.instance
    }
    
    func logged() -> User {
        return loggedUser!
    }
    
    func isLogged() -> Bool {
        return loggedUser != nil
    }
    
    func setLogged(_ user: User) {
        // add token in keychain
        self.loggedUser = user
    }
    
    func logout() {        
        self.loggedUser = nil
        image = nil
    }
}
