//
//  CommentMessageController.swift
//  Streamini
//
//  Created by Vasily Evreinov on 17/07/15.
//  Copyright (c) 2015 UniProgy s.r.o. All rights reserved.
//

import UIKit

class CommentMessageController: NSObject, MessageControllerProtocol {
    var commentsDataSource: CommentsDataSource
    var commentsTableView: UITableView
    let kCommentLiveTime = 7.0
    
    init(commentsTableView: UITableView, commentsDataSource: CommentsDataSource) {
        self.commentsTableView = commentsTableView
        self.commentsDataSource = commentsDataSource
        super.init()
    }

    func handle(_ message: Message) {
        // Remove comment after kCommentLiveTime seconds
        let timer = Timer.scheduledTimer(timeInterval: kCommentLiveTime, target: self, selector: #selector(CommentMessageController.removeLastComment(_:)), userInfo: nil, repeats: false)
        
        // add comment and timer to datasource
        commentsDataSource.addComment(message, timer: timer)
        
        // change opacity of old messages
        let opacities = calculateOpacities()
        for i in 0 ..< commentsTableView.visibleCells.count {
            let indexPath = IndexPath(row: i, section: 0)
            let cell = commentsTableView.cellForRow(at: indexPath) as! CommentCell
            cell.setAlphaValue(CGFloat(opacities[i]))
        }
        
        // show message on top of the table
        let indexPath = IndexPath(row: 0, section: 0)
        commentsTableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.right)
        
        // hide last message if it is out of the table frame
        if !isLastRowFit(commentsTableView.frame.size.height) {
            let indexPath = IndexPath(row: commentsTableView.visibleCells.count-1, section: 0)
            removeCommentAt(indexPath)
        }
    }
    
    @objc func removeLastComment(_ timer: Timer) {
        let lastCell = commentsTableView.visibleCells.count-1
        if lastCell < 0 {
            return
        }
        let lastIndexPath = IndexPath(row: lastCell, section: 0)
        removeCommentAt(lastIndexPath)
    }
    
    fileprivate func calculateOpacities() -> [Double] {
        let count = commentsTableView.visibleCells.count + 1
        let minOpacity: Double = 0.0
        let maxOpacity: Double = 1.0
        let delta: Double = (maxOpacity - minOpacity) / Double(count)
        
        var opacities: [Double] = []
        for i in 0 ..< count-1 {
            opacities.append( maxOpacity - delta * Double(i+1) )
        }
        return opacities
    }
    
    fileprivate func isLastRowFit(_ tableViewHeight: CGFloat) -> Bool {
        let cellsCount = commentsTableView.visibleCells.count
        if cellsCount == 0 {
            return false
        }
        
        var height: CGFloat = 0.0
        for i in 0 ..< cellsCount {
            let indexPath = IndexPath(row: i, section: 0)
            let cellHeight = commentsDataSource.calculateHeight(commentsTableView, indexPath: indexPath)
            height += cellHeight
        }
        
        return height < tableViewHeight
    }
    
    fileprivate func removeCommentAt(_ indexPath: IndexPath) {
        commentsDataSource.removeCommentAt(indexPath.row)
        commentsTableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }
}
