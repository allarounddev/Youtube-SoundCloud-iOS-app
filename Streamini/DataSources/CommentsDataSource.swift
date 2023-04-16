//
//  CommentsDataSource.swift
//  Streamini
//
//  Created by Vasily Evreinov on 16/07/15.
//  Copyright (c) 2015 Evghenii Todorov. All rights reserved.
//

import UIKit

class CommentsDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    var comments: [Message] = []
    var timers: [Timer]   = []
    var userSelectedDelegate: UserSelecting?
    
    var l = CommentLabel()
    var calculatedWidth: CGFloat = 0.0
    
    // MARK: - Object life Cycle
    
    override init() {
        super.init()
        l.numberOfLines = 0
        l.font = UIFont(name: "HelveticaNeue", size: 15.0)
        l.lineBreakMode = NSLineBreakMode.byWordWrapping
    }
    
    // MARK: - Comments accessors
    
    func addComment(_ message: Message, timer: Timer) {
        comments.insert(message, at: 0)
        timers.insert(timer, at: 0)
    }
    
    func removeCommentAt(_ index: Int) {
        comments.remove(at: index)
        timers.removeLast().invalidate()
    }
    
    // MARK: - UITableViewDatasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))

        if let delegate = self.userSelectedDelegate {
            cell.userSelectedDelegate = delegate
        }
        
        let live = comments[indexPath.row]
        cell.update(live, width: calculatedWidth)
        cell.contentView.alpha = 1.0
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return calculateHeight(tableView, indexPath: indexPath)
    }
    
    func calculateHeight(_ tableView: UITableView, indexPath: IndexPath) -> CGFloat {
        l.text = comments[indexPath.row].text
        
        let margins: CGFloat            = 8 + 35 + 8
        let verticalMargins: CGFloat    = 3 + 16 + 3
        
        let width = tableView.frame.size.width - margins
        let expectedSize = l.sizeThatFits(CGSize(width: width, height: 10000))
        calculatedWidth = expectedSize.width
        
        let rowHeight: CGFloat = expectedSize.height + verticalMargins
        let minHeight: CGFloat = verticalMargins + 35.0
        
        return (rowHeight < minHeight) ? minHeight : rowHeight
    }
}
