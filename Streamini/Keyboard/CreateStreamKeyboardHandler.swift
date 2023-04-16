//
//  CreateStreamKeyboardHandler.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CreateStreamKeyboardHandler: NSObject {
    var view: UIView
    var constraint: NSLayoutConstraint
    
    init(view: UIView, constraint: NSLayoutConstraint) {
        self.view           = view
        self.constraint     = constraint
        
        super.init()
    }
    
    func register() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(CreateStreamKeyboardHandler.keyboardWillBeShown(_:)), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(CreateStreamKeyboardHandler.keyboardWillHide(_:)), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }
    
    func unregister() {
        NotificationCenter.default
            .removeObserver(self, name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        
        NotificationCenter.default
            .removeObserver(self, name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
    }
    
    @objc func keyboardWillBeShown(_ notification: Notification) {
        let tmp : [AnyHashable: Any] = notification.userInfo!
        let duration : TimeInterval = tmp[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame : CGRect = (tmp[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.constraint.constant = keyboardFrame.size.height + 10
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let tmp : [AnyHashable: Any] = notification.userInfo!
        let duration : TimeInterval = tmp[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame : CGRect = (tmp[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.constraint.constant = 240
            self.view.layoutIfNeeded()
        })
    }
}
