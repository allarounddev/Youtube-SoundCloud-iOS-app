//
//  JoinStreamKeyboardHandler.swift
//  Streamini
//
//  Created by Vasily Evreinov on 30/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class JoinStreamKeyboardHandler: NSObject {
    var view: UIView
    var messageTextView: UITextView
    var commentsTableView: UITableView
    var commentsTableViewHeight: NSLayoutConstraint
    var viewersCollectionViewHeight: NSLayoutConstraint
    var messageViewBottomConstraint: NSLayoutConstraint
    var viewersLabelBottomConstraint: NSLayoutConstraint
    var messageTextViewRightConstraint: NSLayoutConstraint
    var viewersLabel: UILabel
    var eyeButton: UIButton
    var isRecent = false
    
    init(
            view: UIView,
            messageTextView: UITextView,
            commentsTableView: UITableView,
            commentsTableViewHeight: NSLayoutConstraint,
            viewersCollectionViewHeight: NSLayoutConstraint,
            messageViewBottomConstraint: NSLayoutConstraint,
            messageTextViewRightConstraint: NSLayoutConstraint,
            viewersLabelBottomConstraint: NSLayoutConstraint,
            viewersLabel: UILabel,
            eyeButton: UIButton,
            isRecent: Bool
        )
    {
        self.view                           = view
        self.messageTextView                = messageTextView
        self.commentsTableView              = commentsTableView
        self.commentsTableViewHeight        = commentsTableViewHeight
        self.viewersCollectionViewHeight    = viewersCollectionViewHeight
        self.messageViewBottomConstraint    = messageViewBottomConstraint
        self.viewersLabelBottomConstraint   = viewersLabelBottomConstraint
        self.messageTextViewRightConstraint = messageTextViewRightConstraint
        self.viewersLabel                   = viewersLabel
        self.eyeButton                      = eyeButton
        self.isRecent                       = isRecent
        super.init()
    }
    
    func register() {
        NotificationCenter.default
            .addObserver(self, selector: #selector(JoinStreamKeyboardHandler.keyboardWillBeShown(_:)), name: NSNotification.Name(rawValue: "UIKeyboardWillShowNotification"), object: nil)
        
        NotificationCenter.default
            .addObserver(self, selector: #selector(JoinStreamKeyboardHandler.keyboardWillHide(_:)), name: NSNotification.Name(rawValue: "UIKeyboardWillHideNotification"), object: nil)
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
        
        let h = commentsTableViewHeight.constant - keyboardFrame.size.height + commentsTableView.frame.origin.y/2
        
        while commentsTableView.visibleCells.count > 0 && !isLastRowFit(h) {
            let indexPath = IndexPath(row: commentsTableView.visibleCells.count-1, section: 0)
            removeCommentAt(indexPath)
        }
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.messageTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
            let viewersHeight = self.viewersCollectionViewHeight.constant
            self.commentsTableViewHeight.constant        = h
            self.messageViewBottomConstraint.constant    = keyboardFrame.size.height + 8 - viewersHeight
            self.viewersLabelBottomConstraint.constant   = keyboardFrame.size.height + 8 - viewersHeight
            if !self.isRecent {
                self.messageTextViewRightConstraint.constant = 8.0
            }
            self.viewersLabel.alpha                      = 0.0
            self.eyeButton.alpha                         = 0.0
            self.view.layoutIfNeeded()
        })
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        let tmp : [AnyHashable: Any] = notification.userInfo!
        let duration : TimeInterval = tmp[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let keyboardFrame : CGRect = (tmp[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: duration, animations: { () -> Void in
            self.messageTextView.backgroundColor = UIColor(white: 1.0, alpha: 0.2)
            self.commentsTableViewHeight.constant        = 360
            self.messageViewBottomConstraint.constant    = 8.0
            self.viewersLabelBottomConstraint.constant   = 8.0
            if !self.isRecent {
                self.messageTextViewRightConstraint.constant = 43.0
            }
            self.viewersLabel.alpha                      = 1.0
            self.eyeButton.alpha                         = 1.0
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func isLastRowFit(_ tableViewHeight: CGFloat) -> Bool {
        let cellsCount = commentsTableView.visibleCells.count
        if cellsCount == 0 {
            return false
        }
        
        let dataSource = commentsTableView.dataSource as! CommentsDataSource
        var height: CGFloat = 0.0
        for i in 0 ..< cellsCount {
            let indexPath = IndexPath(row: i, section: 0)
            let cellHeight = dataSource.calculateHeight(commentsTableView, indexPath: indexPath)
            height += cellHeight
        }
        
        return height < tableViewHeight
    }
    
    fileprivate func removeCommentAt(_ indexPath: IndexPath) {
        let dataSource = commentsTableView.dataSource as! CommentsDataSource
        dataSource.removeCommentAt(indexPath.row)
        commentsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
}
